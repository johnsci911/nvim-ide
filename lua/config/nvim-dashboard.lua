vim.g.dashboard_custom_header = {
    ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
    ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
    ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
    ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
    ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
    ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
}

vim.g.dashboard_default_executive = 'telescope'

vim.g.dashboard_custom_section = {
    a = {description = {'  Find File           '}, command = 'FzfLua files'},
    b = {description = {'  Recently Used Files '}, command = 'FzfLua oldfiles'},
    p = {description = {'  Projects            '}, command = 'Telescope project'},
    e = {description = {'  Config              '}, command = ':cd ~/.config/nvim | :FzfLua files'},
    w = {description = {'  Web Projects        '}, command = ':cd ~/Documents/www | :FzfLua files'},
    -- e = {description = {'  Marks              '}, command = 'Telescope marks'}
}

-- vim.g.dashboard_session_directory = '~/.cache/nvim/session'
vim.g.dashboard_custom_footer = {'Neovim Lua'}
