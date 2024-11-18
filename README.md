# Linux

These are the steps I follow when setting up a new Linux machine.

# Setup

### Updates

After a fresh install, it's a good idea to make sure everything is up to date.

```
sudo apt update
sudo apt upgrade -y
```

### Git

Make sure to replace the `git config` values with your information.

```
sudo apt install git
git config --global user.name "Joe Scotto"
git config --global user.email "contact@joescotto.com"
git config --global init.defaultBranch main
ssh-keygen -t ed25519 -C "contact@joescotto.com"
cat ~/.ssh/ # Add to https://github.com/settings/ssh
```

### Node

It is important to confirm the script matches [nodejs.org](https://nodejs.org/en/download/package-manager).

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
exec bash
nvm install 23`
```

### Automount

This will automatically mount devices when they are plugged into USB.

1. Install [pmount](https://github.com/MisterDA/pmount).
   `sudo apt install pmount`
2. Setup `usbstick` rules.
   `sudo nano /etc/udev/rules.d/usbstick.rules`
   ```
   ACTION=="add", KERNEL=="sd[a-z][0-9]", TAG+="systemd", ENV{SYSTEMD_WANTS}="usbstick-handler@%k"
   ```
3. Setup `usbstick` service.
   `sudo nano /lib/systemd/system/usbstick-handler@.service`

   ```
   [Unit]
   Description=Mount USB sticks
   BindsTo=dev-%i.device
   After=dev-%i.device

   [Service]
   Type=oneshot
   RemainAfterExit=yes
   ExecStart=/usr/local/bin/automount %I
   ExecStop=/usr/bin/pumount /dev/%I
   ```

4. Setup `automount` script.
   `sudo nano /usr/local/bin/automount`

   ```
   #!/bin/bash

   PART=$1
   FS_LABEL=`lsblk -o name,label | grep ${PART} | awk '{print $2}'`

   if [ -z ${FS_LABEL} ]
   then
       /usr/bin/pmount --umask 000 --noatime -w --sync /dev/${PART} /media/${PART}
   else
       /usr/bin/pmount --umask 000 --noatime -w --sync /dev/${PART} /media/${FS_LABEL}
   fi
   ```

5. Reload `udevadm`
   ```
   sudo chmod +x /usr/local/bin/automount
   udevadm control --reload
   ```

### Quality of Life

1. Disable MOTD
   ```
   sudo nano /etc/motd # Delete everything in this file
   touch ~/.hushlogin
   ```

# ZSH

1. Install ZSH.
   ```
   sudo apt install zsh zplug
   ```
2. Powerlevel10k theme.
   ```
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
   ```
3. Setup `.zshrc` configuration.
   `sudo nano ~/.zshrc`

   ```
   # PIPX
   export PATH="$PATH:/home/jscotto/.local/bin"

   # NodeJS
   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

   # P10k
   ZSH_THEME="powerlevel10k/powerlevel10k"
   source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
   [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

   # Auto cd
   setopt autocd

   #ZSH history
   HISTSIZE=1000
   SAVEHIST=1000
   HISTFILE=~/.zsh_history
   ```

4. Set ZSH as default shell.
   ```
   chsh -s /bin/zsh
   ```

# Tmux

1. Install [tmux](https://github.com/tmux/tmux).
   ```
   sudo apt install tmux
   ```
2. Install [tpm](https://github.com/tmux-plugins/tpm).
   ```
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```
3. Setup `~.tmux.conf`.

   ```
   # Fix colors
   set -g default-terminal "screen-256color"
   set -as terminal-features ",xterm-256color:RGB"
   set -g mouse on

   # TPM
   set -g @plugin 'tmux-plugins/tpm'
   set -g @plugin 'tmux-plugins/tmux-sensible'

   # Dracula
   set -g @plugin 'dracula/tmux'
   set -g @dracula-plugins "cpu-usage ram-usage time"
   set -g @dracula-show-left-icon session
   set -g @dracula-refresh-rate 1
   set -g @dracula-show-timezone false
   set -g @dracula-border-contrast true

   # Run TPM
   run '~/.tmux/plugins/tpm/tpm'

   # Force pane color
   set -g pane-active-border-style bg=default,fg="#4b4f66"
   set -g pane-border-style fg="#4b4f66"
   ```

4. Reload tmux config.
   ```
   tmux source ~/.tmux.conf
   ```

# NeoVim

1. Install [NeoVim](https://github.com/neovim/neovim).
   ```
   sudo apt-get install ninja-build gettext cmake unzip curl build-essential
   git clone https://github.com/neovim/neovim
   cd neovim
   git checkout stable
   make distclean
   make CMAKE_BUILD_TYPE=Release
   cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
   rm-rf neovim
   ```
2. Install [NvChad](https://github.com/NvChad/starter).
   ```
   git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
   ```
3. Setup NvChad configuration.
   `sudo nano ~/.config/nvim/lua/chadrc.lua`

   ```
   -- This file needs to have same structure as nvconfig.lua
   -- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
   -- Please read that file to know all available options :(

   ---@type ChadrcConfig
   local M = {}

   M.base46 = {
     theme = "chadracula",
   }

   -- Copy to clipboard

   -- Disable line wrapping
   local opt = vim.opt
   opt.wrap = false

   -- Conform auto formatting
   require("conform").setup {
     formatters_by_ft = {
       angular = { "prettier" },
       css = { "prettier" },
       flow = { "prettier" },
       graphql = { "prettier" },
       html = { "prettier" },
       json = { "prettier" },
       jsx = { "prettier" },
       javascript = { "prettier" },
       less = { "prettier" },
       markdown = { "prettier" },
       scss = { "prettier" },
       typescript = { "prettier" },
       vue = { "prettier" },
       yaml = { "prettier" },
     },
     format_on_save = {
       lsp_format = "fallback",
     },
   }

   -- Render markdown
   require("render-markdown").setup {}

   return M
   ```

   `sudo nano ~/.config/nvim/lua/plugins/init.lua`

   ```
   return {
     {
       "stevearc/conform.nvim",
       event = "BufWritePre", -- uncomment for format on save
       opts = require "configs.conform",
     },
     {
       "neovim/nvim-lspconfig",
       config = function()
         require "configs.lspconfig"
       end,
     },
     {
       "mg979/vim-visual-multi",
       lazy = false,
       init = function()
         vim.g.VM_maps = {
           ["Find Under"] = "<C-j>",
           ["Find Subword Under"] = "<C-j>",
         }
         vim.g.VM_theme = "purplegray"
       end,
     },
     {
       "MeanderingProgrammer/render-markdown.nvim",
       dependencies = {
         "nvim-treesitter/nvim-treesitter",
       },
       opts = {},
     },
   }
   ```

4. Install plugins.
   ```
   :MasonInstallAll
   :Lazy install
   :TSInstall c markdown json
   ```
