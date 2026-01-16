vim.o.completeopt = "menuone,noselect"

local cmp = require 'cmp'
local lspkind = require('lspkind')

local source_mapping = {
    buffer = "[Buffer]",
    nvim_lsp = "[LSP]",
    nvim_lua = "[Lua]",
    minuet = "[AI]",
    path = "[Path]",
    supermaven = "[⚡]"
}

cmp.setup {
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
        end,
    },
    mapping = {
        ["<c-x>"] = require('minuet').make_cmp_map(),
        ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-c>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        })
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    sources = cmp.config.sources(
        {
            { name = 'nvim_lsp' },
            { name = 'vsnip' }, -- For vsnip users.
            -- { name = 'luasnip' }, -- For luasnip users.
            -- { name = 'ultisnips' }, -- For ultisnips users.
            -- { name = 'snippy' }, -- For snippy users.
            { name = 'path' },
            { name = 'supermaven' },
        },
        {
            { name = 'buffer' },
        }
    ),
    completion = {
        autoComplete = false
    },
    formatting = {
        format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 80,
            ellipsis_char = "...",
            before = function(entry, vim_item)
                vim_item.menu = source_mapping[entry.source.name]

                if entry.source.name == "minuet" then
                    local detail = (entry.completion_item.labelDetails or {}).detail

                    vim_item.kind = ""

                    if detail and detail:find('.*%%.*') then
                        vim_item.kind = vim_item.kind .. ' ' .. detail
                    end

                    if (entry.completion_item.data or {}).multiline then
                        vim_item.kind = vim_item.kind .. ' ' .. '[ML]'
                    end
                end

                return require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
            end,
        }),
    },
}
