# Linux

These are the steps I follow when setting up a new Linux machine.

### Setup

1.  Updates

    After a fresh install, it's a good idea to make sure everything is up to date.

    ```
    sudo apt update
    sudo apt upgrade -y
    ```

2.  Git
    ```
    sudo apt install git
    git config --global user.name "Joe Scotto"
    git config --global user.email "contact@joescotto.com"
    git config --global init.defaultBranch main
    ssh-keygen -t ed25519 -C "contact@joescotto.com"
    cat ~/.ssh/
    ```
3.  Node
    It is important to confirm the script matches [nodejs.org](https://nodejs.org/en/download/package-manager).
    ```
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    exec bash
    nvm install 23
    ```
4.  Automount
    This will allow devices to automatically mount when plugging them into USB ports.

    ```

    ```
