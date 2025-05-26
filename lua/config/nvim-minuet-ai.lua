local minuet = require('minuet')

minuet.setup {
    -- provider = 'openai_fim_compatible',
    provider = 'openai',
    n_completions = 1, -- recommend for local model for resource saving
    -- I recommend beginning with a small context window size and incrementally
    -- expanding it, depending on your local computing power. A context window
    -- of 512, serves as an good starting point to estimate your computing
    -- power. Once you have a reliable estimate of your local computing power,
    -- you should adjust the context window to a larger value.
    context_window = 512,
    provider_options = {
        openai_fim_compatible = {
            api_key = 'TERM',
            name = 'Ollama',
            end_point = 'http://localhost:11434/v1/completions',
            model = 'qwen2.5-coder:7b',
            optional = {
                max_tokens = 56,
                top_p = 0.9,
            },
        },
        openai = {
            model = 'gpt-4.1-mini',
            stream = true,
            api_key = 'OPENAI_API_KEY',
            optional = {
                -- stop = { 'end' },
                -- max_tokens = 256,
                -- top_p = 0.9,
            }
        },
    },
    presets = {
        preset_1 = {
            request_timeout = 4,
            throttle = 3000,
            provider = 'openai',
            provider_options = {
                openai = {
                    model = 'gpt-4.1-mini',
                    stream = true,
                    api_key = 'OPENAI_API_KEY',
                    optional = {
                        -- stop = { 'end' },
                        -- max_tokens = 256,
                        -- top_p = 0.9,
                    }
                }
            }
        },
        preset_2 = {
            provider = 'openai_fim_compatible',
            context_window = 2000,
            throttle = 400,
            debounce = 100,
            provider_options = {
                openai_fim_compatible = {
                    api_key = 'TERM',
                    name = 'Ollama',
                    end_point = 'http://localhost:11434/v1/completions',
                    model = 'qwen2.5-coder:7b',
                    optional = {
                        max_tokens = 56,
                        top_p = 0.9,
                    },
                },
            }
        }
    },
}

vim.api.nvim_create_autocmd("User", {
  pattern = "MinuetRequestStartedPre",
  callback = function()
    vim.notify("Minuet request started")
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "MinuetRequestFinishedPost",
  callback = function()
    vim.notify("Minuet request finished")
  end,
})

