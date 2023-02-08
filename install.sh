#!/bin/bash

# install script for git status watch; the even lazier person's lazygit

function installgsw() {
    clear
    echo "Default install path is ~/.local/bin, but you can install globally to /usr/bin instead, if you prefer."
    echo
    read -p "Would you like to install gsw globally [y]? " varinstall

    if [ "$varinstall" = "y" ]; then
        sudo cp ./gsw.sh /usr/bin/gsw
        echo
        echo "Global installation complete! Thanks for picking gsw!"
        exit 0
    else
        mkdir -p ~/.local/bin/
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            export PATH=$PATH:$HOME/.local/bin
        fi
        cp ./gsw.sh ~/.local/bin/gsw
        echo "User-land installation complete! Thanks for picking gsw!"
        exit 0
    fi
}

function updatecheck() {
    varalready=$(which gsw)
    if [ -z "$varalready" ]; then
        installgsw
    else
        varversion=$(gsw -v)
        if [ "$varversion" = "v 2.0" ]; then
            echo "You're already up to date!"
            exit 0
        fi
        echo "Updating..."
        gswinstallpath=$(echo $varalready | sed 's/gsw//')
        if [ "$gswinstallpath" = "/usr/bin/" ]; then
            sudo rm $varalready
            sudo cp ./gsw.sh /usr/bin/gsw
        else
            rm $varalready
            cp ./gsw.sh ~/.local/bin/gsw
        fi
        echo "Update complete! Thanks for staying with us!"
        exit 0
    fi
}

updatecheck
