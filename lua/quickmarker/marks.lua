local path = require('plenary.path')
local qm = require('quickmarker')

local M = {}

-- Creates a mark at the current cursor position
local function create_mark(filename)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    return {
        filename = filename,
        row = cursor_pos[1],
        col = cursor_pos[2],
    }
end

local function mark_exists(mark)
    for _, m in ipairs(qm.get_current_project_marks()) do
        if mark.filename == m.filename then
            return true
        end
    end

    return false
end

-- create a mark at the current cursor position and add it to the list of marks
function M.add_file()
    -- get the filename relative to the project working directory
    local filename = path:new(vim.api.nvim_buf_get_name(0)):make_relative(vim.fn.getcwd())
    local new_mark = create_mark(filename)

    -- if the mark exists, do nothing
    if mark_exists(new_mark) then
        return
    end

    -- add the new mark to the current project list
    local marks = qm.get_current_project_marks()
    local idx = table.maxn(marks)
    marks[idx + 1] = new_mark

    -- save the projects to disk
    qm.save_projects()
end

return M
