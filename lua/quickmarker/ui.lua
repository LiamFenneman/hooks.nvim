local popup = require('plenary.popup')
local qm = require('quickmarker')
local marks = require('quickmarker.marks')
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

local function get_menu_items()
    local lines = vim.api.nvim_buf_get_lines(menu_bufnr, 0, -1, true)
    local indices = {}

    for _, line in pairs(lines) do
        if not utils.is_white_space(line) then
            table.insert(indices, line)
        end
    end

    return indices
end

function M.on_menu_save()
    marks.set_marks_list(get_menu_items())
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
        contents[i] = string.format('%s', mark.filename)
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

local function get_or_create_buffer(filename)
    local buf_exists = vim.fn.bufexists(filename) ~= 0
    if buf_exists then
        return vim.fn.bufnr(filename)
    end

    return vim.fn.bufadd(filename)
end

function M.nav_file(idx)
    local marks = qm.get_current_project_marks()

    -- ensure the index is within the marks array bounds
    if idx > table.maxn(marks) then
        return
    end

    local mark = marks[idx]
    local filename = vim.fs.normalize(mark.filename)
    local bufnr = get_or_create_buffer(filename)
    local set_row = not vim.api.nvim_buf_is_loaded(bufnr)

    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'buflisted', true)
    if set_row and mark.row and mark.col then
        vim.fn.cursor({ mark.row, mark.col })
    end
end

vim.api.nvim_create_user_command('MarkerToggleMenu', M.toggle_menu, {})
vim.api.nvim_create_user_command('MarkerSelectItem', M.select_menu_item, {})

return M
