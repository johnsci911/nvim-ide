local reload = require'nvim-reload'

local plugin_dirs = DATA_PATH .. '/site/pack/packer/start/packer.nvim'

reload.vim_reload_dirs = {
	CONFIG_PATH,
	plugin_dirs
}

reload.lua_reload_dirs = {
	CONFIG_PATH,
	plugin_dirs
}

reload.modules_reload_external = { 'packer' }
