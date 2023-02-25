<h2 align="center">Neovim PDE - Personalized Development Environment</h2>

![image](https://user-images.githubusercontent.com/6580895/199143031-c8975cd8-b71a-415b-9727-3f0fa7753282.png)

<h5 align="center">A neovim configuration base from the vim community</h5>

#### Awesome Plugins that are used
- **lsp-trouble** - to jumping between lsp warnings
- **nvim-treesitter** - for accurate syntax highlighting
- **vim-windowswap** - to swap windows
- **nvim-telescope** - to preview files while searching
- **ctrlsf.vim** and **vim-visual-multi** - to find and replace some text with multi-cursor support
- **vim-easy-align** - (gaip) Easy align texts
- **Neoclip** - Clipboard

#### What's new
- MultiCursor support
- Mighty FZF
- C# (Omnisharp WIP)
- Re-add Galaxyline status line
- Winbar - LSP breadcumbs
- Notifications
- Clipboards!
- Migrated to Mason (LSP install manager) and Lazy.nvim (Faster loading package manager)

#### Packages Required
- Neovim 0.9+ (required)
- ripgrep
- fd and Chafa - for some reason required by Telescope media files
- fzf

##### Compatible OS
- Mac and Linux
- Windows - You have to use your own docker container or equivalent - **I don't know about this...**

#### LSP Auto-install
* bash
* css
* html
* json
* lua
* php
* python
* vim
* yaml
* vue
* emmet ls
* c-sharp
* TailwindCSS
* GraphQL

#### TODO
* Improve Keybindings along the way
* Formatters for various web frameworks
* Add FZF symbols, diagnostics, etcx9999999, in keybinds
* Work on Nvim-notification plugin
