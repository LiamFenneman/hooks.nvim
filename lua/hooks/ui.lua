local popup = require('plenary.popup')
local h = require('hooks')
local hooks = require('hooks.marks')
local utils = require('hooks.utils')

local M = {}

local menu_id = nil
local menu_bufnr = nil

local function create_window()
    local config = h.get_config().menu
    local bufnr = vim.api.nvim_create_buf(false, true)

    local width = config.width
    local height = config.height

    local id = popup.create(bufnr, {
        title = 'Hooks',
        highlight = 'HooksWindow',
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
    hooks.set_hooks_list(get_menu_items())
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
    for i, hook in ipairs(h.get_current_project_hooks()) do
        contents[i] = string.format('%s', hook.filename)
    end

    -- window and buffer set options
    vim.api.nvim_win_set_option(menu_id, 'number', true)
    vim.api.nvim_buf_set_option(menu_bufnr, 'filetype', 'hooks')
    vim.api.nvim_buf_set_option(menu_bufnr, 'buftype', 'acwrite')
    vim.api.nvim_buf_set_option(menu_bufnr, 'bufhidden', 'delete')
    vim.api.nvim_buf_set_lines(menu_bufnr, 0, #contents, false, contents)

    -- default keymaps
    vim.api.nvim_buf_set_keymap(menu_bufnr, 'n', 'q', '<Cmd>HooksToggleMenu<CR>', { silent = true })
    vim.api.nvim_buf_set_keymap(menu_bufnr, 'n', '<ESC>', '<Cmd>HooksToggleMenu<CR>', { silent = true })
    vim.api.nvim_buf_set_keymap(menu_bufnr, 'n', '<CR>', '<Cmd>HooksSelectItem<CR>', {})

    -- autocommands
    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
        callback = function()
            M.on_menu_save()
        end,
        group = h.group,
        buffer = menu_bufnr,
    })
    vim.api.nvim_create_autocmd('BufModifiedSet', {
        command = 'set nomodified',
        group = h.group,
        buffer = menu_bufnr,
    })
    vim.api.nvim_create_autocmd('BufLeave', {
        callback = function()
            M.on_menu_save()
            M.toggle_menu()
        end,
        group = h.group,
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
    local hooks = h.get_current_project_hooks()

    -- ensure the index is within the hooks array bounds
    if idx > table.maxn(hooks) then
        return
    end

    local hook = hooks[idx]
    local filename = vim.fs.normalize(hook.filename)
    local bufnr = get_or_create_buffer(filename)
    local set_row = not vim.api.nvim_buf_is_loaded(bufnr)

    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'buflisted', true)
    if set_row and hook.row and hook.col then
        vim.fn.cursor({ hook.row, hook.col })
    end
end

vim.api.nvim_create_user_command('HooksToggleMenu', M.toggle_menu, {})
vim.api.nvim_create_user_command('HooksSelectItem', M.select_menu_item, {})

return M
