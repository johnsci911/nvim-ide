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
    {icon = ' ', desc = 'Find File             ', action = 'FzfLua files'},
    {icon = ' ', desc = 'Recently Used Files   ', action = 'FzfLua oldfiles'},
    {icon = ' ', desc = 'Projects              ', action = 'Telescope project'},
    {icon = ' ', desc = 'Config                ', action = ':cd ~/.config/nvim | :FzfLua files'},
    {icon = ' ', desc = 'Marks                 ', action = 'Telescope marks'},
    {icon = ' ', desc = 'Sessions              ', action = 'SearchSession'},
}

db.session_directory = '~/.cache/nvim/session'
db.custom_footer = {'Neovim Lua'}

