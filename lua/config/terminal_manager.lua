local M = {}

-- Registry to track terminal names
M.terminal_registry = {}

-- Function to register a terminal with a name
M.register_terminal = function(name)
    local index = #M.terminal_registry + 1
    M.terminal_registry[index] = name
    return index
end

-- Get all registered terminals as a string (for debugging)
M.get_registered_names = function()
    return vim.inspect(M.terminal_registry)
end

-- Function to get the most recently registered terminal name
M.get_last_registered_name = function()
    local pos = #M.terminal_registry
    if pos > 0 then
        return M.terminal_registry[pos]
    end
    return "Terminal"
end

return M

