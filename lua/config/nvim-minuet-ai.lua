require('minuet').setup {
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
            -- For Windows users, TERM may not be present in environment variables.
            -- Consider using APPDATA instead.
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
}
