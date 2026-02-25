local M = {}

-- Default agents.md path (can be customized)
local DEFAULT_AGENTS_PATH = vim.fn.stdpath("config") .. "/agents.md"

-- Agent definitions cache
local agents_cache = {}

---Parse agents.md file
---Format expected:
---# Agents
---
---## Agent Name
---Description of the agent
---
---```yaml
---name: agent_name
---description: Agent description
---prompt: |
---  System prompt for the agent
---tools:
---  - tool1
---  - tool2
---```
local function parse_agents_md(content)
  local agents = {}
  
  -- Simple markdown parsing
  local current_agent = nil
  
  for line in content:gmatch("[^\r\n]+") do
    -- Check for H2 (##) headers - agent names
    if line:match("^##%s+(.+)$") then
      if current_agent then
        table.insert(agents, current_agent)
      end
      local name = line:match("^##%s+(.+)$")
      current_agent = {
        name = name:lower():gsub("%s+", "-"),
        display_name = name,
        description = "",
        prompt = "",
        tools = {},
      }
    elseif current_agent then
      -- Check for description (non-code blocks)
      if not line:match("^```") and current_agent.description == "" and line:match("^%S") then
        current_agent.description = line:gsub("^%s+", ""):gsub("%s+$", "")
      -- Check for YAML code block start
      elseif line:match("^```yaml%s*$") or line:match("^```%s*$") then
        -- Start of code block - will parse YAML content
      -- Check for YAML content
      elseif line:match("^%s+name:%s*(.+)$") and current_agent.name == "" then
        current_agent.name = line:match("^%s+name:%s*(.+)$"):gsub("%s+$", "")
      elseif line:match("^%s+description:%s*(.+)$") then
        current_agent.description = line:match("^%s+description:%s*(.+)$"):gsub("%s+$", "")
      elseif line:match("^%s+prompt:%s*|%s*$") then
        -- Multi-line prompt starts
        current_agent.prompt = ""
      elseif line:match("^%s+prompt:%s*(.+)$") and current_agent.prompt == "" then
        current_agent.prompt = line:match("^%s+prompt:%s*(.+)$")
      elseif current_agent.prompt ~= "" and line:match("^%s{2,}.+") then
        -- Continuation of prompt
        current_agent.prompt = current_agent.prompt .. "\n" .. line:gsub("^%s+", "")
      elseif line:match("^%s+-%s+(.+)$") then
        local tool = line:match("^%s+-%s+(.+)$"):gsub("%s+$", "")
        table.insert(current_agent.tools, tool)
      end
    end
  end
  
  -- Add last agent
  if current_agent then
    table.insert(agents, current_agent)
  end
  
  return agents
end

---Load agents from file
function M.load_agents(path)
  path = path or DEFAULT_AGENTS_PATH
  
  -- Check cache first
  if agents_cache[path] then
    return agents_cache[path]
  end
  
  local file = io.open(path, "r")
  if not file then
    return {}
  end
  
  local content = file:read("*a")
  file:close()
  
  if content == "" then
    return {}
  end
  
  local agents = parse_agents_md(content)
  agents_cache[path] = agents
  
  return agents
end

---Get agent by name
function M.get_agent(name, path)
  local agents = M.load_agents(path)
  for _, agent in ipairs(agents) do
    if agent.name == name or agent.display_name:lower() == name:lower() then
      return agent
    end
  end
  return nil
end

---List all available agents
function M.list_agents(path)
  return M.load_agents(path)
end

---Reload agents (clear cache)
function M.reload_agents(path)
  path = path or DEFAULT_AGENTS_PATH
  agents_cache[path] = nil
  return M.load_agents(path)
end

-- Default tool groups (sub-agents) available in CodeCompanion
M.default_tool_groups = {
  {
    name = "coding_agent",
    display_name = "Coding Agent",
    description = "Full coding agent with all tools",
    tools = {
      "cmd_runner",
      "create_file",
      "delete_file",
      "file_search",
      "grep_search",
      "insert_edit_into_file",
      "list_code_usages",
      "read_file",
      "get_changed_files",
    },
  },
  {
    name = "code_review",
    display_name = "Code Review",
    description = "Review code and provide suggestions",
    tools = {
      "grep_search",
      "read_file",
      "list_code_usages",
    },
  },
  {
    name = "file_ops",
    display_name = "File Operations",
    description = "Create, read, edit, and delete files",
    tools = {
      "create_file",
      "read_file",
      "insert_edit_into_file",
      "delete_file",
    },
  },
  {
    name = "search",
    display_name = "Search Agent",
    description = "Search and find code across workspace",
    tools = {
      "grep_search",
      "file_search",
      "list_code_usages",
    },
  },
}

---Get available tool groups (sub-agents)
function M.get_tool_groups()
  return M.default_tool_groups
end

---Get tool group by name
function M.get_tool_group(name)
  for _, group in ipairs(M.default_tool_groups) do
    if group.name == name then
      return group
    end
  end
  return nil
end

---Display agents in a chooser (using Telescope or builtin)
function M.show_agents_selector(path, callback)
  local agents = M.load_agents(path)
  
  if #agents == 0 then
    vim.notify("No agents found in agents.md", vim.log.levels.INFO, { title = "CodeCompanion Agents" })
    return
  end
  
  -- Build picker items
  local items = {}
  for _, agent in ipairs(agents) do
    table.insert(items, {
      name = agent.display_name,
      description = agent.description,
      agent = agent,
    })
  end
  
  -- Try to use Telescope if available
  local ok, telescope = pcall(require, "telescope")
  if ok then
    telescope.pickers.new({}, {
      prompt_title = "Select Agent",
      finder = telescope.finders.new_table({
        results = items,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name .. " - " .. entry.description,
            ordinal = entry.name .. " " .. entry.description,
          }
        end,
      }),
      sorter = telescope.conf.file_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        local actions = require("telescope.actions")
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = require("telescope.actions.state").get_selected_entry()
          if selection and callback then
            callback(selection.value.agent)
          end
        end)
        return true
      end,
    }):find()
  else
    -- Fallback to builtin vim.ui.select
    vim.ui.select(items, {
      prompt = "Select Agent:",
      format_item = function(item)
        return item.name .. " - " .. item.description
      end,
    }, function(choice)
      if choice and callback then
        callback(choice.agent)
      end
    end)
  end
end

---Display tool groups (sub-agents) selector
function M.show_tool_groups_selector(callback)
  local groups = M.get_tool_groups()
  
  if #groups == 0 then
    vim.notify("No tool groups available", vim.log.levels.INFO, { title = "CodeCompanion Sub-Agents" })
    return
  end
  
  -- Try to use Telescope if available
  local ok, telescope = pcall(require, "telescope")
  if ok then
    telescope.pickers.new({}, {
      prompt_title = "Select Sub-Agent (Tool Group)",
      finder = telescope.finders.new_table({
        results = groups,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.display_name .. " - " .. entry.description,
            ordinal = entry.display_name .. " " .. entry.description,
          }
        end,
      }),
      sorter = telescope.conf.file_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        local actions = require("telescope.actions")
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = require("telescope.actions.state").get_selected_entry()
          if selection and callback then
            callback(selection.value)
          end
        end)
        return true
      end,
    }):find()
  else
    -- Fallback to builtin vim.ui.select
    vim.ui.select(groups, {
      prompt = "Select Sub-Agent:",
      format_item = function(item)
        return item.display_name .. " - " .. item.description
      end,
    }, function(choice)
      if choice and callback then
        callback(choice)
      end
    end)
  end
end

return M
