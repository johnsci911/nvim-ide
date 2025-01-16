<h2 align="center">Neovim PDE - Personalized Development Environment</h2>

![Neovim](https://github.com/johnsci911/nvim-ide/assets/6580895/c663b535-d5de-4f37-afdf-231c9bf4a698)

<h5 align="center">A neovim configuration base from the vim community</h5>

#### Awesome Plugins that are used
- **Tabnine** - AI base autocompletion integrated with cmp
    - After all plugins are installed you'll need to build tabnine
        - `cd ~/.local/share/nvim/lazy/tabnine-nvim/chat`
        - `cargo build --release`
- **lsp-trouble** - to jumping between lsp warnings
- **nvim-treesitter** - for accurate syntax highlighting
- **vim-windowswap** - to swap windows
- **nvim-telescope** - to preview files while searching
- **ctrlsf.vim** and **vim-visual-multi** - to find and replace some text with multi-cursor support
- **vim-easy-align** - (gaip) Easy align texts
- **Neoclip** - Clipboard
- **Neorg** - ORG Mode for organization (Similar to Emacs)

#### What's new
- C# (Omnisharp WIP)
- Re-add Galaxyline status line
- Notifications
- Clipboards!
- Lazy.nvim (Faster loading package manager)
- Tabnine autocompletion support
- Update Icon to fix nerd fonts incompatibility
- Laravel blade syntax highlighting (Beta) 🔥
- Neogit - for GIT superpowers
- TMUX navigation
    * Config: ~/.tmux.conf
        ```
        set-option -sa terminal-overrides ",xterm*:Tc"

        # Options to make tmux more pleasant
        set -g mouse on

        # List of plugins
        set -g @plugin 'tmux-plugins/tpm'
        set -g @plugin 'tmux-plugins/tmux-sensible'
        set -g @plugin 'christoomey/vim-tmux-navigator'
        set -g @plugin 'tmux-plugins/tmux-cpu'
        set -g @plugin 'catppuccin/tmux#v2.1.2'

        # Catpuccin Theme
            set -g @catpuccin_flavor 'mocha'

            # Configure the catppuccin plugin
            set -g @catppuccin_flavor "mocha"
            set -g @catppuccin_window_status_style "rounded"

            # Load catppuccin
            run ~/.config/tmux/plugins/catppuccin/tmux/catppuccin.tmux
            # For TPM, instead use `run ~/.config/tmux/plugins/tmux/catppuccin.tmux`

            # Make the status line pretty and add some modules
            set -g status-right-length 100
            set -g status-left-length 100
            set -g status-left ""
            set -g status-right "#{E:@catppuccin_status_application}"
            set -agF status-right "#{E:@catppuccin_status_cpu}"
            set -ag status-right "#{E:@catppuccin_status_session}"
            set -ag status-right "#{E:@catppuccin_status_uptime}"

            run ~/.config/tmux/plugins/tmux-plugins/tmux-cpu/cpu.tmux
            # Or, if using TPM, just run TPM
        # End Catpuccin theme

        # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
        run '~/.tmux/plugins/tpm/tpm'

        unbind C-b
        set-option -g prefix M-s
        bind-key M-s send-prefix

        # VIM Movement between panes
        # smart pane switching with awareness of vim splits
        bind C-h select-pane -L
        bind C-j select-pane -D
        bind C-k select-pane -U
        bind C-l select-pane -R

        bind M-r command-prompt -p "Rename pane:" "select-pane -T '%%'"
        bind C-s command-prompt -p "Rename session:" -I "#S" "rename-session '%%'"
        bind C-n command-prompt -p "New session name:" "new-session -s '%%'"
        ```

#### Packages Required
- Neovim >= 0.10.2
- ripgrep
- fzf, fd and Chafa - Required by Telescope media files
- Tabnine code complection (Create your own account. Free version is awesome)
- Neorg Note taking plugin (GCC 14+)
- Silicon - Required for <b>nvim-silicon</b> a code snapshot plugin
- Cargo
- Python

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

#### TODO
* Formatters for various web frameworks (disabled by default)
* Fix 'FzfLua files' command in whichkey
* Git-graph (Disabled for now)
* [Yazi](https://github.com/sxyazi/yazi) as file manager. [Installation here!](https://yazi-rs.github.io/docs/installation/#homebrew)
