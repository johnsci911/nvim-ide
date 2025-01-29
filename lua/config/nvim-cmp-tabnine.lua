-- Configuration for nvim-cmp-tabnine
local cmp_tabnine = require('cmp_tabnine.config')

cmp_tabnine:setup({
	max_lines = 1000,
	max_num_results = 20,
	sort = true,
	run_on_every_keystroke = true,
	snippet_placeholder = '..',
	ignored_file_types = {
		-- default is not to ignore
		-- uncomment to ignore in lua:
		-- lua = true
	},
	show_prediction_strength = true,
	min_percent = 0
})

-- Configuration for nvim-tabnine
local tabnine = require('tabnine')

tabnine.setup({
  disable_auto_comment = true,
  accept_keymap = "<Tab>",
  dismiss_keymap = "<C-]>",
  debounce_ms = 800,
  suggestion_color = { gui = "#8087A2", cterm = 244 },
  codelens_color = { gui = "#8087A2", cterm = 244 },
  exclude_filetypes = { "TelescopePrompt", "NvimTree" },
  log_file_path = nil, -- Absolute path to Tabnine log file
})
