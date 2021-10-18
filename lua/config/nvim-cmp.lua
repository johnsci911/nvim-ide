vim.o.completeopt = "menuone,noselect"

local cmp = require'cmp'
local lspkind = require'lspkind'

cmp.setup {
    snippet = {
      expand = function(args)
        -- For `vsnip` user.
        vim.fn["vsnip#anonymous"](args.body)

        -- For `luasnip` user.
        -- require('luasnip').lsp_expand(args.body)

        -- For `ultisnips` user.
        -- vim.fn["UltiSnips#Anon"](args.body)
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
    sources = {
        { name = 'nvim_lsp' },

        -- For vsnip user.
        { name = 'vsnip' },

        -- For luasnip user.
        -- { name = 'luasnip' },

        -- For ultisnips user.
        -- { name = 'ultisnips' },

        { name = 'buffer' },
		{ name = 'path'},
		{ name = 'cmp_tabnine'},
    },
    completion = {
        autoComplete = false
    },
    formatting = {
        format = lspkind.cmp_format({
            with_text = true,
            menu = {
                Text = '  ',
                Method = '  ',
                Function = '  ',
                Constructor = '  ',
                Variable = '[]',
                Class = '  ',
                Interface = ' 蘒',
                Module = '  ',
                Property = '  ',
                Unit = ' 塞 ',
                Value = '  ',
                Enum = ' 練',
                Keyword = '  ',
                Snippet = '  ',
                Color = '',
                File = '',
                Folder = ' ﱮ ',
                EnumMember = '  ',
                Constant = '  ',
                Struct = '  '
            },
        })
    }
}
