<h2 align="center">Neovim PDE - Personalized Development Environment</h2>

![Neovim](https://github.com/johnsci911/nvim-ide/assets/6580895/c663b535-d5de-4f37-afdf-231c9bf4a698)

<h5 align="center">A neovim configuration base from the vim community</h5>

#### Awesome Plugins that are used
- **lsp-trouble** - to jump between lsp warnings
- **nvim-treesitter** - for accurate syntax highlighting
- **nvim-telescope** - to preview files while searching
- **ctrlsf.vim** and **vim-visual-multi** - to find and replace text with multi-cursor support
- **vim-easy-align** - (gaip) Easy align texts
- **Neoclip** - Clipboard
- **Neorg** - ORG Mode for organization (Similar to Emacs)
- **CodeCompanion** AI chat superpowers (I added a model switcher feature: <leader>ais)
- **AI** - Supermaven (online), cmp minuet (offline) - Code suggestion while you type.

#### What's new
- Fast AI tools - (CodeCompanion, Supermaven, Minuet) 🔥
- Re-add Galaxyline status line - (Will replace because of compatibility issues)
- Clipboards!
- Laravel blade syntax highlighting (Still Beta)
- Neogit - for GIT superpowers
- Toggleterm - Replaced vim-floaterm since I want the ability to rename and select terminals

#### Packages Required
- Neovim 0.11.*
- MCP Hub (Required for CodeCompanion)
- ripgrep
- fzf, fd - Required by Telescope
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
* emmet ls
* c-sharp
* TailwindCSS
* GraphQL
* svelte
* typescript

#### Custom Syntax Highlighting
* Blade
* Vue - custom typescript config since it's not supported as of now

#### Linters
- md - ~/.vale.ini
    ```
    MinAlertLevel = suggestion

    [*.md]
    IgnoreRules = Vale.spelling
    ```

#### I hate arrow keys :)
* If using Karabiner-Elements
    * Go to `~/.config/karabiner/` and edit `karabiner.json`
    ```json
    {
        "global": { "show_in_menu_bar": false },
        "machine_specific": { "krbn-empty-machine-identifier": { "enable_multitouch_extension": true } },
        "profiles": [
            {
                "complex_modifications": {
                    "rules": [
                        {
                            "description": "Play/Pause using Global + Space",
                            "manipulators": [
                                {
                                    "from": {
                                        "key_code": "spacebar",
                                        "modifiers": { "mandatory": ["fn"] }
                                    },
                                    "to": [{ "key_code": "play_or_pause" }],
                                    "type": "basic"
                                }
                            ]
                        },
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
                "fn_function_keys": [
                    {
                        "from": { "key_code": "f5" },
                        "to": [{ "apple_vendor_top_case_key_code": "illumination_down" }]
                    },
                    {
                        "from": { "key_code": "f6" },
                        "to": [{ "apple_vendor_top_case_key_code": "illumination_up" }]
                    }
                ],
                "name": "Personal",
                "selected": true,
                "virtual_hid_keyboard": { "keyboard_type_v2": "ansi" }
            }
        ]
    }
    ```

- Install omnisharp (UNIX) [MAC-OS]
    ```bash
    curl -L https://github.com/OmniSharp/omnisharp-roslyn/releases/latest/download/omnisharp-osx.tar.gz -o omnisharp-osx.tar.gz
    tar -xzf omnisharp-osx.tar.gz
    chmod +x ./omnisharp
    sudo mv ./omnisharp /usr/local/bin/omnisharp
    ```

#### TODO
* Formatters for frameworks (disabled by default)
* Git-graph (Disabled for now)
* [Yazi](https://github.com/sxyazi/yazi) as file manager. [Installation here!](https://yazi-rs.github.io/docs/installation/#homebrew)
* Remove bloat
