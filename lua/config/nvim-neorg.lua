require("neorg").setup {
    load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {
            config = {
                icon_preset = "basic",
                icons = {},
            },
        },
        ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
                workspaces = {
                    home = "~/notes/home", -- $HOME/notes
                    work = "~/notes/work", -- $HOME/notes
                },
                default_workspace = "home"
            },
        },
    },
}
