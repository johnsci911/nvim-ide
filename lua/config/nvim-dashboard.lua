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
    {icon = ' ', shortcut = 'SPC P', desc = 'Projects        ',  action = 'Telescope project'},
    {icon = ' ', shortcut = 'e', desc = 'Config              ',  action = ':cd ~/.config/nvim | :FzfLua files'},
    {icon = ' ', shortcut = 'm', desc = 'Marks               ',  action = 'Telescope marks'},
    {icon = ' ', shortcut = 'SPC S s', desc = 'Sessions      ',  action = 'SearchSession'},
}

db.session_directory = '~/.cache/nvim/session'
db.custom_footer = {'Neovim Lua'}

