#!/usr/bin/env bash
# gsw - ᚫᚻ - Alex Haskins, 2025, under the MIT License. Go nuts with this code, fam. 
# install script for gsw; the even-lazier person's lazygit

install_deps() {
    # Whatever distro-family you're on, I've got you. 
    # Submit a PR for your own distro's repos. eg, nala, yay, nix, brew, pacstall, chocolately, whatever. 
    # Please include package-names.
    if command -v dnf &> /dev/null; then
        sudo dnf install tree git
    elif command -v apt &> /dev/null; then
        sudo apt install tree git
    elif command -v pacman &> /dev/null; then
        sudo pacman -S tree git
    fi
}

install_binary(){
    cd `git rev-parse --show-toplevel`
    sudo cp ./gsw /usr/bin/gsw
    echo "Installation complete! Thanks for picking gsw!"
}

# Only run this function if the script is executed directly,
# NOT if it is being sourced by another script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_deps
    install_binary
    exit 0
fi