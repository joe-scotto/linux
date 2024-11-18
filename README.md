# Linux

These are the steps I follow when setting up a new Linux machine.

### Setup

1. Updates
   ```
   sudo apt update
   sudo apt upgrade -y
   ```
2. Git
   ```
   sudo apt install git
   git config --global user.name "Joe Scotto"
   git config --global user.email "contact@joescotto.com"
   git config --global init.defaultBranch main
   ssh-keygen -t ed25519 -C "contact@joescotto.com"
   cat ~/.ssh/
   ```
3. Node
   ```
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
   exec bash
   nvm install 23
   ```
