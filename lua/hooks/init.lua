local path = require('plenary.path')
local utils = require('hooks.utils')
local ui = require('hooks.ui')

local M = {}
local state = {}

local folder_path = vim.fn.stdpath('data') .. '/hooks'
local projects_path = string.format('%s/projects.json', folder_path)

--- Creates a new project table.
local function create_project()
    return {
        name = vim.fn.getcwd(),
        hooks = {},
    }
end

--- Saves all projects to disk.
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

--- Loads all projects from disk, populating the plugin state.
local function load_projects()
    -- if the projects file doesn't exist or is empty, create it
    if (not path:new(projects_path):exists()) or (path:new(projects_path):read() == '') then
        -- init the projects table
        state.projects = {}

        -- add the current project to the state
        local c = create_project()
        state.projects[c.name] = {
            hooks = c.hooks,
        }

        -- save projects to disk
        save_projects()
        return
    end

    -- read and decode projects from disk
    state.projects = vim.fn.json_decode(path:new(projects_path):read())

    -- check if the current working directory has a project
    local cwd = vim.fn.getcwd()
    if state.projects[cwd] == nil then
        local c = create_project()
        state.projects[c.name] = {
            hooks = c.hooks,
        }
        save_projects()
    end
end

--- Default configuration for the plugin.
local default_config = {
    menu = {
        width = 60,
        height = 10,
        border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    },
    mappings = {
        add_file = '<leader>a',
        toggle_menu = '<leader>e',
        nav_file = {
            [1] = '<leader>1',
            [2] = '<leader>2',
            [3] = '<leader>3',
            [4] = '<leader>4',
        },
    },
}

--- Initializes the plugin and merges any user-defined config with the default.
function M.setup(cfg)
    cfg = cfg or {}
    -- merge such that default config is overridden by the user-defined config
    cfg = utils.merge_tbl(default_config, cfg)
    state.config = cfg

    -- load project from disk
    load_projects()

    -- setup keymaps
    local maps = state.config.mappings
    vim.keymap.set({ 'n', 'v' }, maps.add_file, M.add_file, { desc = '[A]dd hook' })
    vim.keymap.set({ 'n', 'v' }, maps.toggle_menu, '<CMD>HooksToggleMenu<CR>', { desc = 'Toggle hooks menu' })
    for i, v in ipairs(maps.nav_file) do
        vim.keymap.set({ 'n', 'v' }, v, function() ui.nav_file(i, M.get_hooks()) end, { desc = string.format('Go to hook [%s]', i) })
    end
end

--- Creates a hook with the provided filename.
local function create_hook(filename)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    return {
        filename = filename,
        row = cursor_pos[1],
        col = cursor_pos[2],
    }
end

--- Returns the list of hooks for the current project.
function M.get_hooks()
    local cwd = vim.fn.getcwd()
    return state.projects[cwd].hooks
end

--- Sets the list of hooks to the new list.
--- `new_hooks` is a list of strings for the relatie paths
function M.set_hooks(new_hooks)
    local hooks = M.get_hooks()
    -- loop over the new hooks, get the hook from the file or create a new hook
    -- update the new list inplace with the hook
    for k, v in pairs(new_hooks) do
        if type(v) == 'string' then
            local hook = hooks[v]
            if not hook then
                hook = create_hook(v)
            end
            new_hooks[k] = hook
        end
    end

    local cwd = vim.fn.getcwd()
    state.projects[cwd].hooks = new_hooks
    save_projects()
end

--- Returns `true` if the provided hook exists. Otherwise `false`.
local function hook_exists(hook)
    for _, m in ipairs(M.get_hooks()) do
        if hook.filename == m.filename then
            return true
        end
    end

    return false
end

--- Adds the file for the current buffer to the list of hooks.
function M.add_file()
    -- get the filename relative to the project working directory
    local filename = utils.normalise_path(vim.api.nvim_buf_get_name(0))
    local new_hook = create_hook(filename)

    -- if the hook exists, do nothing
    if hook_exists(new_hook) then
        return
    end

    -- add the new hook to the current project list
    local hooks = M.get_hooks()
    local idx = table.maxn(hooks)
    hooks[idx + 1] = new_hook

    -- save the projects to disk
    save_projects()
end

--- Callback function to set the hooks when the menu is saved.
local function on_menu_save()
    M.set_hooks(ui.get_menu_items())
end

--- Navigates to the hook at the cursors position.
--- Note: the menu must be open for this to work.
local function select_menu_item()
    local idx = vim.fn.line('.')
    ui.close_menu()
    ui.nav_file(idx, M.get_hooks())
end

-- user commands
vim.api.nvim_create_user_command('HooksToggleMenu', function()
    ui.toggle_menu(state.config, M.get_hooks(), on_menu_save)
end, {})
vim.api.nvim_create_user_command('HooksSelectItem', select_menu_item, {})

return M
