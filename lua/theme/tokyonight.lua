vim.cmd([[
	if (has("termguicolors"))
	  set termguicolors
	endif

	set background=dark
	colorscheme tokyonight
]])

-- Tokyonight

-- The theme comes in two styles, "storm" and a darker variant "night".
vim.g.tokyonight_style = "storm"

-- Comments are italicized by default
vim.g.tokyonight_italic_comments = true

-- Keywords are italicized by default
vim.g.tokyonight_italic_keywords = true

-- Functions are not italicized by default
vim.g.tokyonight_italic_functions = true

-- Enable this to disable setting the background color
vim.g.tokyonight_transparent = false

-- Enabling this option, will hide inactive statuslines and
-- replace them with a thin border instead. Should work with
-- the standard `StatusLine` and `LuaLine`.
vim.g.tokyonight_hide_inactive_statusline = true
