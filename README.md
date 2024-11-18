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

# Raspberry PI

If not using a Raspberry Pi, you can skip these steps.

1. Disable `power_save`.

   `sudo nano /etc/systemd/system/wlan0pwr.service`

   ```
   [Unit]
   Description=Disable wlan0 powersave
   After=network-online.target
   Wants=network-online.target

   [Service]
   Type=oneshot
   ExecStart=/sbin/iw wlan0 set power_save off

   [Install]
   WantedBy=multi-user.target
   ```

   `sudo systemctl enable wlan0pwr`

2. Overclock
   ```
   [all]
   arm_freq=2000
   ```
3. SSH over USB-C.

   `sudo apt install dnsmasq dhcpcd5`

   ```
   sudo chmod ugo+rwx /boot/firmware/config.txt
   sudo chmod ugo+rwx /boot/firmware/cmdline.txt
   sudo chmod ugo+rwx /etc/modules
   sudo chmod ugo+rwx /etc/dhcpcd.conf
   ```

   ```
   # sudo nano /boot/firmware/config.txt
   dtoverlay=dwc2 # after [all]

   # sudo nano /boot/firmware/cmdline.txt
   modules-load=dwc2 # end of file

   # sudo nano /etc/modules
   libcomposite # end of file

   # sudo nano /etc/dhcpcd.conf
   denyinterfaces usb0 # end of file
   ```

   ```
   # sudo nano /etc/dnsmasq.d/usb
   interface=usb0
   dhcp-range=10.55.0.2,10.55.0.6,255.255.255.248,1h
   dhcp-option=3
   leasefile-ro

   # sudo nano /etc/network/interfaces.d/usb0
   auto usb0
   allow-hotplug usb0
   iface usb0 inet static
       address 10.55.0.1
       netmask 255.255.255.248

   # sudo nano /root/usb.sh
   #!/bin/bash
   cd /sys/kernel/config/usb_gadget/
   mkdir -p pi4
   cd pi4
   echo 0x1d6b > idVendor # Linux Foundation
   echo 0x0104 > idProduct # Multifunction Composite Gadget
   echo 0x0100 > bcdDevice # v1.0.0
   echo 0x0200 > bcdUSB # USB2
   echo 0xEF > bDeviceClass
   echo 0x02 > bDeviceSubClass
   echo 0x01 > bDeviceProtocol
   mkdir -p strings/0x409
   echo "fedcba9876543211" > strings/0x409/serialnumber
   echo "Joe Scotto" > strings/0x409/manufacturer
   echo "RPI4" > strings/0x409/product
   mkdir -p configs/c.1/strings/0x409
   echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration
   echo 250 > configs/c.1/MaxPower
   # Add functions here
   # see gadget configurations below
   # End functions
   mkdir -p functions/ecm.usb0
   HOST="00:dc:c8:f7:75:14" # "HostPC"
   SELF="00:dd:dc:eb:6d:a1" # "BadUSB"
   echo $HOST > functions/ecm.usb0/host_addr
   echo $SELF > functions/ecm.usb0/dev_addr
   ln -s functions/ecm.usb0 configs/c.1/
   udevadm settle -t 5 || :
   ls /sys/class/udc > UDC
   ifup usb0
   service dnsmasq restart
   ```

   `sudo chmod +x /root/usb.sh`

   ```
   # sudo nano /etc/rc.local
   sh /root/usb.sh # add before "exit 0"
   ```

   `sudo reboot`

# QMK

1. Install PIPX
   ```
   sudo apt install pipx
   pipx ensurepath
   pipx install qmk
   ```
2. Setup [QMK](https://github.com/qmk/qmk_firmware).
   ```
   qmk setup joe-scotto/qmk_firmware # replace with your repo
   qmk doctor
   ```
3. Update git.
   ```
   git remote remove origin
   git remote remove upstream
   git remote add origin git@github.com:joe-scotto/qmk_firmware.git
   git remote add upstream git@github.com:qmk/qmk_firmware.git
   git push —set-upstream origin master
   ```
