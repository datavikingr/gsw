#!/bin/bash

#simple bash script for polling git status updates with a janky UI; run this in tmux or terminal that can split; even another window, if you're into that.

### Function defintions ###
function help() {
	echo "gsw - Git Status Watch(er)"
	echo 
	echo "usage: gsw [-t X] [-r filepath]"	
	echo "  -t <int> time in seconds (default 10 seconds)"
	echo "  -r <filepath to repository>"
	echo
	echo "Intended usage is screen/tmux scenario, to keep live track of changes to your local repo."
	echo "However, new windows are also viable, especially when working in GUI editors or DEs in general."
}

function mainloop() {
	clear
	echo "-------------------------------------------------------------------------------"
	echo "|"
	echo "|    You're currently watching '$(pwd)'."
	echo "|    Your branch is: '$(git branch)'."
	echo "|"
	echo "|    Press y to commit, Ctrl+C to exit."
	echo "|"
	echo "-------------------------------------------------------------------------------"
	echo
	echo "Logs:"
	echo "-------------------------------------------------------------------------------"
	git log --graph -n 5 --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
	echo
	echo "Status:"
	echo "-------------------------------------------------------------------------------"
	git status
	echo
	read -t $polltime -n 1 -p "Would you like to add and commit? [y] " varcommit
	if [ "$varcommit" = "y" ]; then
		cd $repository
		echo
		git add .
		read -p "What's your commit message? " varmsg
		git commit -m "$varmsg"
		read -p "Shortname? Defaults to origin: " varremote
		if [ -z "$varremote" ]; then
			varremote="origin"
			echo
		fi
		read -p "Branch? Defaults to main: " varbranch
		if [ -z "$varbranch" ]; then
			varbranch="main"
			echo
		fi
		git push "$varremote" "$varbranch"
		# OLD; Replacing with exit-prompt.
		# echo
		# echo "Thanks for coding with us. Hope it helped!"
		# exit 1
		read -p "Would you like to exit [e] or continue [anything else]? " varcont
		if [ "$varcont" = "e" ]; then
			echo
			echo "Thanks for coding with us! Hope it helped!"
			exit 1
		else
			echo
			echo "Sweet! Let's keep going!!"
			sleep 5
			clear
			mainloop
		fi
	else 
		echo ""
	fi
}

### INITIALIZE - which seems hilariously late in the script
### Chekcing for argument inputs
while getopts t:r:h: flag
do
    case "${flag}" in
        r) repository=${OPTARG};;
        t) polltime=${OPTARG};; 
        h) help;;
    esac
done

# Welcome
clear
echo "Welcome to gsw - git status watch, an even lazier person's lazygit."
echo

# Initialization cleanup time
# Repo var check; defaults to pwd
if [ -z "$repository" ]; then
	repository=$(pwd)
fi

# Transport; .git check
cd $repository

varisgit=$(find . -maxdepth 1 -mindepth 1 -type d -name ".git")
if [ -z "$varisgit" ]; then
	echo "No git repository found in the current directory. Exiting."
	exit 2
fi
echo

# Poll-time check
if [ -z "$polltime" ]; then
	polltime="10"
fi

# Pull check
read -p "Would you like to pull before getting started? " varpull
if [[ "$varpull" == "y" ]]; then
	cd $repository
	read -p "Remote shortname? Defaults to origin: " varremote
	if [ -z "$varremote" ]; then
		varremote="origin"
		echo
	fi
	read -p "Branch? Defaults to main: " varbranch
	if [ -z "$varbranch" ]; then
		varbranch="main"
		echo
	fi
	git pull "$varremote" "$varbranch"
else 
	echo	
fi

# Main body, a simple and effective inifinite while loop.
while :
do
	mainloop	
done
