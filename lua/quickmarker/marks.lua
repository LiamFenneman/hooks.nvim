local qm = require('quickmarker')
local utils = require('quickmarker.utils')

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
    local filename = utils.normalise_path(vim.api.nvim_buf_get_name(0))
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

function M.set_marks_list(new_marks)
    local marks = qm.get_current_project_marks()
    -- loop over the new marks, get the mark from the file or create a new mark
    -- update the new list inplace with the mark
    for k, v in pairs(new_marks) do
        if type(v) == 'string' then
            local mark = marks[v]
            if not mark then
                mark = create_mark(v)
            end
            new_marks[k] = mark
        end
    end

    -- set the project marks to the new list
    qm.set_current_project_marks(new_marks)
end

return M
