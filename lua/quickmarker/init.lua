local M = {}
local state = {}

local default_config = {
    menu = {
        width = 40,
    },
}

-- Merge two tables into a single table. `t1` overrides `t2`.
-- Source: https://shanekrolikowski.com/blog/love2d-merge-tables/
function merge_tbl(t1, t2)
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

return M
