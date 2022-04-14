#simple bash script for polling git status updates with a shitty UI; run this in tmux or terminal that can split; even another window, if you're into that.

### Function defintions ###
function help() {
	echo "Git Status Poller"
	echo 
	echo "usage: gitstatus.sh [-t X] [-r filepath]"	
	echo "  -t <int> time; 30s, 5m, 2h, etc."
	echo "  -r <filepath to repository>"
	echo
	echo "Intended usage is screen/tmux scenario, to keep track of live changes to your local repo."
}

function mainloop() {
	clear
	echo "-------------------------------------------------------------------------------"
	echo "|    Welcome to the top for git status, kinda."
	echo "|    >You're currently working in '$(pwd)'."
	echo "|    >>Your branch is: '$(git branch)'."
	echo "|"
	echo "|    Press y to commit, Ctrl+C to exit."
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
	read -t $polltime -n 1 -p "Would you like to commit? [y]" varcommit
	if [ "$varcommit" = "y" ]; then
		cd $repository
		git add *
		read -p "What's your commit message? " varmsg
		git commit -m "$varmsg"
		read -p "Remote shortname? " varremote
		read -p "Branch? " varbranch
		git push "$varremote" "$varbranch"
		echo
		echo "Thanks for coding with us. "
		exit 1
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

# Cleanup
clear
# Repo check; defaults to pwd
if [ -z "$repository" ]; then
	repository=$(pwd)
fi
#transport and then Pull check
cd $repository
echo
read -p "Would you like to pull first? " varpull
if [[ "$varpull" == "y" ]]; then
	cd $repository
	read -p "Remote shortname? " varremote
	read -p "Branch? " varbranch
	git pull "$varremote" "$varbranch"
else 
	echo	
fi
# Poll time check
if [ -z "$polltime" ]; then
	echo "Another quick Q:"
	read -p "How frequently would like to poll? Default will be set to 30 seconds " polltime 
fi
# Default check
if [ -z "$polltime" ]; then
	echo "Ah, the classics."
	polltime = "30s"
	echo
fi

# Main body, a simple and effective inifinite while loop.
while :
do
	mainloop	
done
