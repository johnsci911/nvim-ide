local db = require('dashboard')

db.custom_header = {
    ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
    ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
    ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
    ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
    ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
    ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
    '                                                       ',
}

db.default_executive = 'telescope'

db.custom_center = {
    {icon = ' ', shortcut = 'a', desc = 'Find File           ',  action = 'FzfLua files'},
    {icon = ' ', shortcut = 'b', desc = 'Recently Used Files ',  action = 'FzfLua oldfiles'},
    {icon = ' ', shortcut = 'p', desc = 'Projects            ',  action = 'Telescope project'},
    {icon = ' ', shortcut = 'e', desc = 'Config              ',  action = ':cd ~/.config/nvim | :FzfLua files'},
    {icon = ' ', shortcut = 'w', desc = 'Web Projects        ',  action = ':cd ~/Documents/www | :FzfLua files'},
    -- e = {description = {'  Marks              '}, command = 'Telescope marks'}
}

db.session_directory = '~/.cache/nvim/session'
db.custom_footer = {'Neovim Lua'}
