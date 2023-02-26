local path = require('plenary.path')

local U = {}

function U.normalise_path(filename)
    return path:new(filename):make_relative(vim.fn.getcwd())
end

function U.is_white_space(str)
    return str:gsub('%s', '') == ''
end

function U.merge_tbl(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == 'table' then
            if type(t1[k]) == 'table' then
                t1[k] = U.merge_tbl(t1[k], t2[k])
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end

    return t1
end

return U
