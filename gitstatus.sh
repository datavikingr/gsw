#!/usr/bin/bash

#simple bash script for polling git status updates

### Function defintions ###
function help() {
	echo "Git Status Poller"
	echo 
	echo "usage: gitstatus.sh [-t X] [-r filepath]"	
	echo "  -t <int> time in seconds"
	echo "  -r <filepath to repository>"
	echo
	echo "Intended usage is screen/tmux scenario, to keep track of live changes to your local repo."
}

while getopts t:r:h: flag
do
    case "${flag}" in
        r) repository=${OPTARG};;
        t) polltime=${OPTARG};;
        h) help;;
    esac
done

clear
cd $repository
while :
do
	clear
	echo "Welcome to the htop for git status."
	echo "You're currently working in '$(pwd)'."
	echo
	echo "Press Ctrl+c to exit."
	echo
	git log --graph -n 5 --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
	echo
	git status
	sleep $polltime
	read -p "Type Q to quit: " varQ
	if [[ "$varQ" == "Q" ]]; then
	    break
	  fi
done

read -p "Would you like to commit? [y/n]" varcommit
if [[ "$varcommit" == "y" ]]; then
	cd $repository
	git add *
	read -p "What's your commit message? " varmsg
	git commit -m "$varmsg"
	read -p "Remote shortname? " varremote
	read -p "Branch? " varbranch
	git push "$varremote" "$varbranch"
# elif = n
fi
