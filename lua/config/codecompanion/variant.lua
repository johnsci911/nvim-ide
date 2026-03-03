local M = {}

-- Variant levels (low / medium / max)
M.levels = {
  { name = "low",    icon = "🟢", label = "Low",    desc = "Minimal thinking — fast, cheap" },
  { name = "medium", icon = "🟡", label = "Medium", desc = "Balanced thinking — default" },
  { name = "max",    icon = "🔴", label = "Max",    desc = "Maximum thinking — thorough, slow" },
}

-- Schema overrides per provider type and variant.
-- Anthropic: extended_thinking + thinking_budget + max_tokens (maps to temp → form_parameters)
-- OpenAI:    reasoning_effort (maps directly to parameters)
M.schema_overrides = {
  anthropic = {
    low    = { extended_thinking = true, thinking_budget = 1024,   max_tokens = 8192   },
    medium = { extended_thinking = true, thinking_budget = 16000,  max_tokens = 32000  },
    max    = { extended_thinking = true, thinking_budget = 100000, max_tokens = 128000 },
  },
  openai = {
    low    = { reasoning_effort = "low" },
    medium = { reasoning_effort = "medium" },
    max    = { reasoning_effort = "high" },
  },
}

local config_file = vim.fn.stdpath("data") .. "/codecompanion_variant.json"

--- Determine provider type for variant support
---@param adapter_name string
---@param model_name? string
---@return string|nil
function M.get_provider_type(adapter_name, model_name)
  if adapter_name == "anthropic" then return "anthropic" end
  if adapter_name == "openai" then return "openai" end
  if adapter_name == "opencode" then
    model_name = model_name or ""
    if model_name:match("anthropic/") or model_name:match("claude") then
      return "anthropic"
    end
  end
  return nil
end

--- Check if current adapter/model supports thinking variants
---@param adapter_name string
---@param model_name? string
---@return boolean
function M.supports_variants(adapter_name, model_name)
  return M.get_provider_type(adapter_name, model_name) ~= nil
end

--- Get schema overrides for a given adapter/model and variant.
--- Returns table of { field = { default = value } } suitable for deep-merging
--- into a CodeCompanion adapter schema.
---@param adapter_name string
---@param model_name? string
---@param variant? string
---@return table
function M.get_schema_overrides(adapter_name, model_name, variant)
  variant = variant
    or (_G.codecompanion_current_state and _G.codecompanion_current_state.variant)
    or "medium"

  local provider_type = M.get_provider_type(adapter_name, model_name)
  if not provider_type then return {} end

  local overrides = M.schema_overrides[provider_type]
  if not overrides then return {} end

  local variant_config = overrides[variant]
  if not variant_config then return {} end

  -- Convert to schema format: { field = { default = value } }
  local schema = {}
  for key, value in pairs(variant_config) do
    schema[key] = { default = value }
  end
  return schema
end

--- Get display string for a variant (icon + label)
---@param variant? string
---@return string
function M.get_display(variant)
  variant = variant or "medium"
  for _, v in ipairs(M.levels) do
    if v.name == variant then
      return v.icon .. " " .. v.label
    end
  end
  return "🟡 Medium"
end

--- Get short display (just the label) for statusline
---@param variant? string
---@return string
function M.get_short_display(variant)
  variant = variant or "medium"
  for _, v in ipairs(M.levels) do
    if v.name == variant then
      return v.label
    end
  end
  return "Medium"
end

--- Save variant preference to disk
---@param variant string
function M.save(variant)
  local file = io.open(config_file, "w")
  if file then
    file:write(vim.json.encode({ variant = variant }))
    file:close()
  end
end

--- Load variant preference from disk
---@return string
function M.load()
  local file = io.open(config_file, "r")
  if file then
    local content = file:read("*a")
    file:close()
    local ok, data = pcall(vim.json.decode, content)
    if ok and data and data.variant then
      return data.variant
    end
  end
  return "medium"
end

--- Open variant picker via vim.ui.select
---@param on_select fun(variant: string)
function M.pick(on_select)
  local current = (_G.codecompanion_current_state and _G.codecompanion_current_state.variant) or "medium"
  local adapter_name = (_G.codecompanion_current_state and _G.codecompanion_current_state.adapter) or "openai"
  local model_name = (_G.codecompanion_current_state and _G.codecompanion_current_state.model) or ""
  local supported = M.supports_variants(adapter_name, model_name)

  local items = {}
  for _, v in ipairs(M.levels) do
    local prefix = v.name == current and "✓ " or "  "
    local support_tag = (not supported) and "  [n/a for current model]" or ""
    table.insert(items, {
      display = prefix .. v.icon .. " " .. v.label .. "  — " .. v.desc .. support_tag,
      value = v.name,
    })
  end

  vim.ui.select(items, {
    prompt = "Thinking Variant (current: " .. M.get_display(current) .. ")",
    format_item = function(item) return item.display end,
  }, function(choice)
    if choice then
      on_select(choice.value)
    end
  end)
end

return M
