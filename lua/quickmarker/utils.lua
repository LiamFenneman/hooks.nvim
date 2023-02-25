local path = require('plenary.path')

local M = {}

function M.normalise_path(filename)
    return path:new(filename):make_relative(vim.fn.getcwd())
end

return M
