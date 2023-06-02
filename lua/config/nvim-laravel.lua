return {
    cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
    keys = {
        { "<leader>la", ":Laravel artisan<cr>" },
        { "<leader>lr", ":Laravel routes<cr>" },
        {
            "<leader>lt",
            function()
                require("laravel.tinker").send_to_tinker()
            end,
            mode = "v",
            desc = "Laravel Application Routes",
        },
    },
    event = { "VeryLazy" },
    config = function()
        require("laravel").setup()
        require("telescope").load_extension "laravel"

        local notify = require("notify")
        -- this for transparency
        notify.setup({ background_colour = "#000000" })
        -- this overwrites the vim notify function
        vim.notify = notify.notify
    end,
}

