local cfg = require('hooks.config')
local utils = require('hooks.utils')

local M = {}

-- Creates a hook at the current cursor position
local function create_hook(filename)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    return {
        filename = filename,
        row = cursor_pos[1],
        col = cursor_pos[2],
    }
end

local function hook_exists(hook)
    for _, m in ipairs(cfg.get_current_project_hooks()) do
        if hook.filename == m.filename then
            return true
        end
    end

    return false
end

-- create a hook at the current cursor position and add it to the list of hooks
function M.add_file()
    -- get the filename relative to the project working directory
    local filename = utils.normalise_path(vim.api.nvim_buf_get_name(0))
    local new_hook = create_hook(filename)

    -- if the hook exists, do nothing
    if hook_exists(new_hook) then
        return
    end

    -- add the new hook to the current project list
    local hooks = cfg.get_current_project_hooks()
    local idx = table.maxn(hooks)
    hooks[idx + 1] = new_hook

    -- save the projects to disk
    cfg.save_projects()
end

function M.set_hooks_list(new_hooks)
    local hooks = cfg.get_current_project_hooks()
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

    -- set the project hooks to the new list
    cfg.set_current_project_hooks(new_hooks)
end

vim.api.nvim_create_user_command('HooksAddFile', M.add_file, {})

return M
