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

# ZMK Compile ScottoKeeb
function zmkcs() {
    if [ -z "$1" ]; then
	      echo "Usage: ScottoKeeb • MCU • Side • Studio"
    else 
        # Log starting directory
        start_dir="$PWD"
        zmk_dir="/home/jscotto/zmk_firmware"
        scottokeebs_dir="/home/jscotto/scottokeebs"
        scottokeeb_raw=$1
        scottokeeb=${scottokeeb_raw:l}

        # Check for board
        board="nice_nano_v2"

        if [ -n "$2" ]; then
            if [ $2 "==" rp2040 ]; then
                board="sparkfun_pro_micro_rp2040"
            fi
        fi

        # Check for split
        split=""
        build_dir="build/$scottokeeb"

        if [ -n "$4" ]; then
            if [ $3 "==" left ]; then
                split="_left"
                build_dir="build/$scottokeeb_left"
            fi

            if [ $3 "==" right ]; then
                split="_right"
                build_dir="build/$scottokeeb_right"
            fi
        fi

        # Check if studio should be used
        rpc=""
        studio=""

        if [ -n "$4" ]; then
            if [ $4 "==" zmk-studio ]; then
                rpc="-S studio-rpc-usb-uart"
                studio="-DCONFIG_ZMK_STUDIO=y"
            fi
        fi

        # Check if direcotory for board exists
        if [ -d "$scottokeebs_dir/$scottokeeb_raw/ZMK/config" ]; then
            # Activate virtual environment
            source $zmk_dir/.venv/bin/activate

            # Change to ZMK install location
            cd $zmk_dir/app;
            
            # Build firmware
            west build -d $build_dir -p -b $board $rpc -- -DSHIELD=$scottokeeb$split $studio -DZMK_CONFIG="$scottokeebs_dir/$scottokeeb_raw/ZMK/config"

            # Check if Firmware folder exists
            if [ ! -d "$scottokeebs_dir/$scottokeeb_raw/Firmware" ]; then
                mkdir $scottokeebs_dir/$scottokeeb_raw/Firmware
            fi

            # Copy firmware file
            cp $zmk_dir/app/$build_dir/zephyr/zmk.uf2 $scottokeebs_dir/$scottokeeb_raw/Firmware/$scottokeeb$split.uf2

            # Return to starting directory
            cd "$start_dir"

            # Deactivate virtual environment
            deactivate
        else 
            echo "No ZMK config found for: $scottokeeb_raw"
        fi    
    fi
}

