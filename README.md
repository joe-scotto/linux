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

1. Install
   ```
   sudo apt install zsh zplug
   ```
2. Powerlevel10k
   ```
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
   ```
3. Setup `.zshrc`
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
