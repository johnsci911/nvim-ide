<h2 align="center">Neovim PDE - Personalized Development Environment</h2>

![Neovim](https://github.com/johnsci911/nvim-ide/assets/6580895/c663b535-d5de-4f37-afdf-231c9bf4a698)

<h5 align="center">A neovim configuration base from the vim community</h5>

#### Awesome Plugins that are used
- **Tabnine** - AI base autocompletion integrated with cmp (For multi-line autocompletion)
- **lsp-trouble** - to jumping between lsp warnings
- **nvim-treesitter** - for accurate syntax highlighting
- **vim-windowswap** - to swap windows
- **nvim-telescope** - to preview files while searching
- **ctrlsf.vim** and **vim-visual-multi** - to find and replace some text with multi-cursor support
- **vim-easy-align** - (gaip) Easy align texts
- **Neoclip** - Clipboard
- **Neorg** - ORG Mode for organization (Similar to Emacs)
- **Avante.nvim** AI assistant like cursor

#### What's new
- C# (Omnisharp WIP)
- Re-add Galaxyline status line
- Notifications
- Clipboards!
- Lazy.nvim (Faster loading package manager)
- Update Icon to fix nerd fonts incompatibility
- Laravel blade syntax highlighting (Beta) 🔥
- Neogit - for GIT superpowers

#### Packages Required
- Neovim 0.10.2
- ripgrep
- fzf, fd and Chafa - Required by Telescope media files
- Tabnine code complection (Create your own account. Free version is awesome)
- Neorg Note taking plugin (GCC 14+)
- Silicon - Required for <b>nvim-silicon</b> a code snapshot plugin

##### Compatible OS
- Mac and Linux

#### LSP Auto-install
* C++ (clang)
* bash
* css
* html
* json
* lua
* intelephense - (Phpactor if not using paid intelephense)
* python
* vim
* yaml
* vue
* emmet ls
* c-sharp
* TailwindCSS
* GraphQL

#### Custom Syntax Highlighting
* Blade
* Norg - Neo ORG

#### I hate arrow keys :)
* If using Karabiner-Elements
    * Go to `~/.config/karabiner/` and edit `karabiner.json`
    ```
    {
        "profiles": [
            {
                "complex_modifications": {
                    "rules": [
                        {
                            "description": "Use Tab + hjkl for navigation",
                            "manipulators": [
                                {
                                    "from": {
                                        "key_code": "tab",
                                        "modifiers": { "optional": ["any"] }
                                    },
                                    "to": [
                                        {
                                            "set_variable": {
                                                "name": "tab_pressed",
                                                "value": 1
                                            }
                                        }
                                    ],
                                    "to_after_key_up": [
                                        {
                                            "set_variable": {
                                                "name": "tab_pressed",
                                                "value": 0
                                            }
                                        }
                                    ],
                                    "to_if_alone": [{ "key_code": "tab" }],
                                    "type": "basic"
                                },
                                {
                                    "conditions": [
                                        {
                                            "name": "tab_pressed",
                                            "type": "variable_if",
                                            "value": 1
                                        }
                                    ],
                                    "from": {
                                        "key_code": "j",
                                        "modifiers": { "optional": ["any"] }
                                    },
                                    "to": [{ "key_code": "down_arrow" }],
                                    "type": "basic"
                                },
                                {
                                    "conditions": [
                                        {
                                            "name": "tab_pressed",
                                            "type": "variable_if",
                                            "value": 1
                                        }
                                    ],
                                    "from": {
                                        "key_code": "k",
                                        "modifiers": { "optional": ["any"] }
                                    },
                                    "to": [{ "key_code": "up_arrow" }],
                                    "type": "basic"
                                },
                                {
                                    "conditions": [
                                        {
                                            "name": "tab_pressed",
                                            "type": "variable_if",
                                            "value": 1
                                        }
                                    ],
                                    "from": {
                                        "key_code": "h",
                                        "modifiers": { "optional": ["any"] }
                                    },
                                    "to": [{ "key_code": "left_arrow" }],
                                    "type": "basic"
                                },
                                {
                                    "conditions": [
                                        {
                                            "name": "tab_pressed",
                                            "type": "variable_if",
                                            "value": 1
                                        }
                                    ],
                                    "from": {
                                        "key_code": "l",
                                        "modifiers": { "optional": ["any"] }
                                    },
                                    "to": [{ "key_code": "right_arrow" }],
                                    "type": "basic"
                                }
                            ]
                        }
                    ]
                },
                "devices": [
                    {
                        "identifiers": { "is_keyboard": true },
                        "simple_modifications": [
                            {
                                "from": { "apple_vendor_top_case_key_code": "keyboard_fn" },
                                "to": [{ "key_code": "left_control" }]
                            },
                            {
                                "from": { "key_code": "left_command" },
                                "to": [{ "key_code": "left_option" }]
                            },
                            {
                                "from": { "key_code": "left_control" },
                                "to": [{ "apple_vendor_top_case_key_code": "keyboard_fn" }]
                            },
                            {
                                "from": { "key_code": "left_option" },
                                "to": [{ "key_code": "left_command" }]
                            },
                            {
                                "from": { "key_code": "right_option" },
                                "to": [{ "apple_vendor_top_case_key_code": "keyboard_fn" }]
                            }
                        ]
                    }
                ],
                "name": "Personal",
                "selected": true,
                "virtual_hid_keyboard": { "keyboard_type_v2": "ansi" }
            }
        ]
    }

    ```

#### TODO
* Formatters for various web frameworks (disabled by default)
* Fix 'FzfLua files' command in whichkey
* Git-graph (Disabled for now)
* [Yazi](https://github.com/sxyazi/yazi) as file manager. [Installation here!](https://yazi-rs.github.io/docs/installation/#homebrew)
* Avante.nvim - Testing Ollama open source models and OpenAI with it
