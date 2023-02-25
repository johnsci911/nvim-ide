vim.o.completeopt = "menuone,noselect"

local cmp = require'cmp'
-- local lspkind = require'lspkind' -- Undeclared - I have seeing warnings :)

cmp.setup {
    snippet = {
        expand = function(args)
            -- For `vsnip` user.
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
        end,
    },
    mapping = {
        ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-space>'] = cmp.mapping.complete(),
        ['<C-c>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        })
    },
    sources = cmp.config.sources(
        {
            { name = 'nvim_lsp' },
            { name = 'vsnip' }, -- For vsnip users.
            -- { name = 'luasnip' }, -- For luasnip users.
            -- { name = 'ultisnips' }, -- For ultisnips users.
            -- { name = 'snippy' }, -- For snippy users.
            { name = 'path'},
            { name = 'cmp_tabnine'},
        },
        {
            { name = 'buffer' },
        }
    ),
    completion = {
        autoComplete = false
    },
    formatting = {
        format = require('tailwindcss-colorizer-cmp').formatter, -- How to make this work with lspkind?
        -- format = lspkind.cmp_format({
        --     with_text = true,
        --     menu = {
        --         Text = '  ',
        --         Method = '  ',
        --         Function = '  ',
        --         Constructor = '  ',
        --         Variable = '[]',
        --         Class = '  ',
        --         Interface = ' 蘒',
        --         Module = '  ',
        --         Property = '  ',
        --         Unit = ' 塞 ',
        --         Value = '  ',
        --         Enum = ' 練',
        --         Keyword = '  ',
        --         Snippet = '  ',
        --         Color = '',
        --         File = '',
        --         Folder = ' ﱮ ',
        --         EnumMember = '  ',
        --         Constant = '  ',
        --         Struct = '  '
        --     },
        -- })
    }
}

