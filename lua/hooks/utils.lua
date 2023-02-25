local path = require('plenary.path')

local M = {}

function M.normalise_path(filename)
    return path:new(filename):make_relative(vim.fn.getcwd())
end

function M.is_white_space(str)
    return str:gsub('%s', '') == ''
end

return M
