local cmp_ai = require('cmp_ai')

cmp_ai:setup({
  max_lines = 100,
  provider = 'Ollama',
  provider_options = {
    model = 'qwen2.5-coder:7b-base-q6_K',
    prompt = function(lines_before, lines_after)
      return "<|fim_prefix|>" .. lines_before .. "<|fim_suffix|>" .. lines_after .. "<|fim_middle|>"
    end,
    auto_unload = false,
  },
  notify = true,
  notify_callback = function(msg)
    vim.notify(msg)
  end,
  run_on_every_keystroke = true,
  log_errors = true,
})

-- cmp_ai:setup({
--   max_lines = 1000,
--   provider = 'OpenAI',
--   provider_options = {
--     model = 'gpt-3.5-turbo',
--   },
--   notify = true,
--   notify_callback = function(msg)
--     vim.notify(msg)
--   end,
--   run_on_every_keystroke = true,
--   ignored_file_types = {
--     -- default is not to ignore
--     -- uncomment to ignore in lua:
--     -- lua = true
--   },
-- })
