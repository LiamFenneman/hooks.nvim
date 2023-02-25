local popup = require('plenary.popup')

local M = {}
local state = {}

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

-- Setup the config for the plugin
function M.setup(cfg)
    local cfg = cfg or {}
    -- merge such that default config is overridden by the user-defined config
    local cfg = merge_tbl(default_config, cfg)
    state.config = cfg
end

-- Setup quickmarker with default config
M.setup()

local menu_id = nil
local menu_bufnr = nil

local function create_window()
    local config = state.config.menu
    local bufnr = vim.api.nvim_create_buf(false, false)

    local width = config.width
    local height = config.height

    local id, win = popup.create(bufnr, {
        title = 'QuickMarker',
        highlight = 'QuickMarkerWindow',
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        border = true,
        borderchars = config.border_chars,
    })

    menu_id = id
    menu_bufnr = bufnr
end

function M.toggle_menu()
    if menu_id ~= nil and vim.api.nvim_win_is_valid(menu_id) then
        vim.api.nvim_win_close(menu_id, true)
        menu_id = nil
        menu_bufnr = nil
        return
    end

    create_window()

    -- window and buffer set options
    vim.api.nvim_win_set_option(menu_id, 'number', true)
    vim.api.nvim_buf_set_option(menu_bufnr, 'filetype', 'quickmarker')
    vim.api.nvim_buf_set_option(menu_bufnr, 'buftype', 'acwrite')
    vim.api.nvim_buf_set_option(menu_bufnr, 'bufhidden', 'delete')

    -- default keymaps
    vim.api.nvim_buf_set_keymap(menu_bufnr, 'n', 'q', '<Cmd>MarkerToggleMenu<CR>', { silent = true })
    vim.api.nvim_buf_set_keymap(menu_bufnr, 'n', '<ESC>', '<Cmd>MarkerToggleMenu<CR>', { silent = true })
end

-- create a command to toggle the menu
vim.api.nvim_create_user_command('MarkerToggleMenu', M.toggle_menu, {})

return M
