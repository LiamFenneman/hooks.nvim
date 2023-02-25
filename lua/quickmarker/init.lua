local path = require('plenary.path')

local M = {}
local state = {}

local folder_path = vim.fn.stdpath('data') .. '/quickmarker'
local projects_path = string.format('%s/projects.json', folder_path)

local default_config = {
    menu = {
        width = 60,
        height = 10,
        border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    },
}

M.group = vim.api.nvim_create_augroup('QUICKMARKER', { clear = true })

-- Merge two tables into a single table. `t1` overrides `t2`.
-- Source: https://shanekrolikowski.com/blog/love2d-merge-tables/
local function merge_tbl(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == 'table' then
            t1[k] = merge_tbl(t1[k], t2[k])
        else
            t1[k] = v
        end
    end

    return t1
end

local function create_project()
    return {
        name = vim.fn.getcwd(),
        marks = {},
    }
end

function M.save_projects()
    if state.projects ~= nil then
        -- create the folder if it doesn't exist
        if not path:new(folder_path):exists() then
            path:new(folder_path):mkdir()
        end

        -- write the projects to disk
        path:new(projects_path):write(vim.fn.json_encode(state.projects), 'w')
    end
end

local function load_projects()
    -- if the projects file doesn't exist or is empty, create it
    if (not path:new(projects_path):exists()) or (path:new(projects_path):read() == '') then
        -- init the projects table
        state.projects = {}

        -- add the current project to the state
        local c = create_project()
        state.projects[c.name] = {
            marks = c.marks,
        }

        -- save projects to disk
        M.save_projects()
        return
    end

    -- read and decode projects from disk
    state.projects = vim.fn.json_decode(path:new(projects_path):read())

    -- check if the current working directory has a project
    local cwd = vim.fn.getcwd()
    if state.projects[cwd] == nil then
        local c = create_project()
        state.projects[c.name] = {
            marks = c.marks,
        }
        M.save_projects()
    end
end

function M.get_current_project_marks()
    local cwd = vim.fn.getcwd()
    return state.projects[cwd].marks
end

function M.set_current_project_marks(new_marks)
    local cwd = vim.fn.getcwd()
    state.projects[cwd].marks = new_marks
    M.save_projects()
end

-- Setup the config for the plugin
function M.setup(cfg)
    cfg = cfg or {}
    -- merge such that default config is overridden by the user-defined config
    cfg = merge_tbl(default_config, cfg)
    state.config = cfg

    -- load project from disk
    load_projects()
end

-- Setup quickmarker with default config
M.setup()

function M.get_config()
    return state.config
end

-- removes projects that have no marks (exluding the current project)
function M.cleanup()
    for k, v in pairs(state.projects) do
        if v.marks and #v.marks == 0 and k ~= vim.fn.getcwd() then
            state.projects[k] = nil
        end
    end

    M.save_projects()
end

vim.api.nvim_create_user_command('MarkerCleanup', M.cleanup, {})

return M
