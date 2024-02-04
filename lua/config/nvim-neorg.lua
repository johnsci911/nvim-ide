require('neorg').setup {
  load = {
    ["core.defaults"] = {},
    ["core.intergrations.treesitter"] = {
      configure_parsers = true,
    },
    ["core.dirman"] = {
      config = {
        workspaces = {
          work = "~/notes/work",
          home = "~/notes/home",
        }
      }
    }
  },
}

