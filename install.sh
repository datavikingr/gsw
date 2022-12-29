#!/bin/bash

# install script for git status watch; the even lazier person's lazygit

clear
echo "Default install path is ~/.local/bin, but you can install globally to /usr/bin instead, if you prefer."
echo
read -p "Would you like to install gsw globally [y]? " varinstall

if [ "$varinstall" = "y" ]; then
	sudo cp ./gsw.sh /usr/bin/gsw
	echo
	echo "Installation complete! Thanks for picking gsw!"
	exit 1
else
	cp ./gsw.sh ~/.local/bin
	echo
	echo "Make sure ~/.local/bin is in your $PATH variable."
	echo "You can verify this in your .bashrc, .zshrc, etc. after install."
	echo
	echo "That said, install is complete! Thanks for picking gsw!"
	exit 1
fi
