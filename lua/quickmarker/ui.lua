local popup = require('plenary.popup')
local qm = require('quickmarker')
local utils = require('quickmarker.utils')

local M = {}

local menu_id = nil
local menu_bufnr = nil

local function create_window()
    local config = qm.get_config().menu
    local bufnr = vim.api.nvim_create_buf(false, false)

    local width = config.width
    local height = config.height

    local id = popup.create(bufnr, {
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

local function close_menu()
    vim.api.nvim_win_close(menu_id, true)
    menu_id = nil
    menu_bufnr = nil
end

function M.on_menu_save()
    print('TODO: on_menu_save')
end

function M.select_menu_item()
    local idx = vim.fn.line(".")
    close_menu()
    M.nav_file(idx)
end

function M.toggle_menu()
    if menu_id ~= nil and vim.api.nvim_win_is_valid(menu_id) then
        close_menu()
        return
    end

    create_window()

    local contents = {}
    for i, mark in ipairs(qm.get_current_project_marks()) do
        contents[i] = string.format('%s', mark.filename, mark.row, mark.col)
    end

    -- window and buffer set options
    vim.api.nvim_win_set_option(menu_id, 'number', true)
    vim.api.nvim_buf_set_option(menu_bufnr, 'filetype', 'quickmarker')
    vim.api.nvim_buf_set_option(menu_bufnr, 'buftype', 'acwrite')
    vim.api.nvim_buf_set_option(menu_bufnr, 'bufhidden', 'delete')
    vim.api.nvim_buf_set_lines(menu_bufnr, 0, #contents, false, contents)

    -- default keymaps
    vim.api.nvim_buf_set_keymap(menu_bufnr, 'n', 'q', '<Cmd>MarkerToggleMenu<CR>', { silent = true })
    vim.api.nvim_buf_set_keymap(menu_bufnr, 'n', '<ESC>', '<Cmd>MarkerToggleMenu<CR>', { silent = true })
    vim.api.nvim_buf_set_keymap(menu_bufnr, 'n', '<CR>', '<Cmd>MarkerSelectItem<CR>', {})

    -- autocommands
    vim.api.nvim_create_autocmd('BufModifiedSet', {
        command = 'set nomodified',
        group = qm.group,
        buffer = menu_bufnr,
    })
    vim.api.nvim_create_autocmd('BufLeave', {
        callback = function()
            M.on_menu_save()
            M.toggle_menu()
        end,
        group = qm.group,
        buffer = menu_bufnr,
        once = true,
        nested = true,
    })
end

function M.nav_file(idx)
    print('TODO: nav_file '..idx)
end

vim.api.nvim_create_user_command('MarkerToggleMenu', M.toggle_menu, {})
vim.api.nvim_create_user_command('MarkerSelectItem', M.select_menu_item, {})

return M
