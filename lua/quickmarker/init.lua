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

local function save_projects()
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
    -- if the config file doesn't exist, create it
    if not path:new(projects_path):exists() then
        -- init the projects table
        state.projects = {}

        -- add the current project to the state
        local c = create_project()
        state.projects[c.name] = {
            marks = c.marks,
        }

        -- save projects to disk
        save_projects()
        return
    end

    -- read and decode projects from disk
    state.projects = vim.fn.json_decode(path:new(projects_path):read())
    print(vim.inspect(state.projects))
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

return M
