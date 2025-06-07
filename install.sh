#!/usr/bin/env bash

# install script for git status watch; the even-lazier person's lazygit

if command -v dnf &> /dev/null; then
    sudo dnf install tree git
elif command -v apt &> /dev/null; then
    sudo apt install tree git
elif command -v pacman &> /dev/null; then
    sudo pacman -S tree git
fi

sudo cp ./gsw.sh /usr/bin/gsw
echo
echo "Global installation complete! Thanks for picking gsw!"
exit 0