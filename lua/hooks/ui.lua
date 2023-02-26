local popup = require('plenary.popup')
local utils = require('hooks.utils')

local UI = {}
local group = vim.api.nvim_create_augroup('LF_HOOKS', { clear = true })

-- user interface state
UI.menu = {
    id = nil,
    bufnr = nil,
}

--- Creates a popup menu.
function UI.create_menu(cfg)
    local config = cfg.menu
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

    UI.menu.id = id
    UI.menu.bufnr = bufnr
end

--- Closes the popup menu.
function UI.close_menu()
    vim.api.nvim_win_close(UI.menu.id, true)
    UI.menu.id = nil
    UI.menu.bufnr = nil
end

--- Returns a list of lines from the menu.
function UI.get_menu_items()
    local lines = vim.api.nvim_buf_get_lines(UI.menu.bufnr, 0, -1, true)
    local indices = {}

    for _, line in pairs(lines) do
        if not utils.is_white_space(line) then
            table.insert(indices, line)
        end
    end

    return indices
end

--- Toggles the popup menu.
function UI.toggle_menu(cfg, hooks, on_save)
    if UI.menu.id ~= nil and vim.api.nvim_win_is_valid(UI.menu.id) then
        UI.close_menu()
        return
    end

    UI.create_menu(cfg)

    local contents = {}
    for i, hook in ipairs(hooks) do
        contents[i] = string.format('%s', hook.filename)
    end

    -- window and buffer set options
    vim.api.nvim_win_set_option(UI.menu.id, 'number', true)
    vim.api.nvim_buf_set_option(UI.menu.bufnr, 'filetype', 'hooks')
    vim.api.nvim_buf_set_option(UI.menu.bufnr, 'buftype', 'acwrite')
    vim.api.nvim_buf_set_option(UI.menu.bufnr, 'bufhidden', 'delete')
    vim.api.nvim_buf_set_lines(UI.menu.bufnr, 0, #contents, false, contents)

    -- default keymaps
    vim.api.nvim_buf_set_keymap(UI.menu.bufnr, 'n', 'q', '<Cmd>HooksToggleMenu<CR>', { silent = true })
    vim.api.nvim_buf_set_keymap(UI.menu.bufnr, 'n', '<ESC>', '<Cmd>HooksToggleMenu<CR>', { silent = true })
    vim.api.nvim_buf_set_keymap(UI.menu.bufnr, 'n', '<CR>', '<Cmd>HooksSelectItem<CR>', {})

    -- autocommands
    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
        callback = function()
            -- UI.on_menu_save()
            on_save()
        end,
        group = group,
        buffer = UI.menu.bufnr,
    })
    vim.api.nvim_create_autocmd('BufModifiedSet', {
        command = 'set nomodified',
        group = group,
        buffer = UI.menu.bufnr,
    })
    vim.api.nvim_create_autocmd('BufLeave', {
        callback = function()
            -- UI.on_menu_save()
            on_save()
            UI.close_menu()
        end,
        group = group,
        buffer = UI.menu.bufnr,
        once = true,
        nested = true,
    })
end

--- Returns a buffer number after retriving an existing buffer or creating a new one.
local function get_or_create_buffer(filename)
    local buf_exists = vim.fn.bufexists(filename) ~= 0
    if buf_exists then
        return vim.fn.bufnr(filename)
    end

    return vim.fn.bufadd(filename)
end

--- Navigates to a file from the list of hooks.
function UI.nav_file(idx, hooks)
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

return UI
