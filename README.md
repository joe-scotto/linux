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

1. `sudo apt install pmount`
2. `sudo nano /etc/udev/rules.d/usbstick.rules`
   ```
   ACTION=="add", KERNEL=="sd[a-z][0-9]", TAG+="systemd", ENV{SYSTEMD_WANTS}="usbstick-handler@%k"
   ```
