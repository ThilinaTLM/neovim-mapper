local M = {}

KEY_MAPPER_RHS = {1}
local function mem_save(value)
    KEY_MAPPER_RHS[1] = KEY_MAPPER_RHS[1] + 1
    KEY_MAPPER_RHS[KEY_MAPPER_RHS[1]] = value
    return KEY_MAPPER_RHS[1]
end

local function mem_get_lua(key)
    return 'KEY_MAPPER_RHS['..key..']'
end

M.map = function(mode, lhs, rhs, opts)
    -- default values and sanity checks
    if opts == nil then opts = {noremap = true, silent = true} end
    local prefix = opts.prefix or ''
    local rhs_type = opts.type
    if rhs_type == nil then
        if type(rhs) == 'function' then rhs_type = 'function' end
    end
    opts.type = nil
    opts.prefix = nil

    -- mappings
    if rhs_type == 'function' then
        local lua_func = mem_get_lua(mem_save(rhs))
        vim.api.nvim_set_keymap(mode, prefix..lhs, string.format("<cmd>lua (%s)()<CR>", lua_func), opts)
    elseif rhs_type == 'command' then
        -- if rsh is a command
        vim.api.nvim_set_keymap(mode, prefix..lhs, string.format("<cmd>%s<CR>", rhs), opts)
    elseif rhs_type == 'lua' then
        -- if rsh is a lua expression
        vim.api.nvim_set_keymap(mode, prefix..lhs, string.format("<cmd>lua %s<CR>", rhs), opts)
    else
        -- if rsh is a string
        vim.api.nvim_set_keymap(mode, prefix..lhs, rhs, opts)
    end
end

M.new_mapper = function(mode, opts)
    return function(lhs, rhs, more_opts)
        local new_opts = {}
        if opts ~= nil then
            for k, v in pairs(opts) do
                new_opts[k] = v
            end
        end
        if more_opts ~= nil then
            for k, v in pairs(more_opts) do
                new_opts[k] = v
            end
        end
        M.map(mode, lhs, rhs, new_opts)
    end
end

M.qmap = {
    map = M.new_mapper('', {silent = false, noremap = true}),
    nmap = M.new_mapper('n', {silent = false, noremap = true}),
    vmap = M.new_mapper('v', {silent = false, noremap = true}),
    imap = M.new_mapper('i', {silent = false, noremap = true}),
    nlmap = M.new_mapper('n', {prefix = '<leader>', silent = false, noremap = true}),
    vlmap = M.new_mapper('v', {prefix = '<leader>', silent = false, noremap = true}),
    ilmap = M.new_mapper('i', {prefix = '<leader>', silent = false, noremap = true}),
}

M.set_leader = function(key) vim.g.mapleader = key end

return M
