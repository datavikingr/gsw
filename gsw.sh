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
	echo "However, new windows are also viable, especially working in GUI editors."
}

function mainloop() {
	clear
	echo "-------------------------------------------------------------------------------"
	echo "|"
	echo "|    You're currently working in '$(pwd)'."
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
	read -t $polltime -n 1 -p "Would you like to commit? [y]" varcommit
	if [ "$varcommit" = "y" ]; then
		cd $repository
		echo
		git add *
		read -p "What's your commit message? " varmsg
		git commit -m "$varmsg"
		read -p "Shortname? Defaults to origin. " varremote
		if [ -z "$varremote" ]; then
			varremote = "origin"
			echo
		fi
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

# Welcome
clear
echo "Welcome to gsw - git status watch, and even lazier person's lazygit."
echo

# Initialization cleanup time
# Repo var check; defaults to pwd
if [ -z "$repository" ]; then
	repository=$(pwd)
	echo "No repository given in flags, defaulting to working directory."
fi

# Transport; .git check
cd $repository

### This isn't triggering correctly
### Don;t forget to update installed version - copy/paste style.

varisgit=$(find . -maxdepth 1 -type d -name ".git")
if [ -z "$varisgit" ]; then
	echo "No git repository found. Exiting."
	exit 2
fi
echo

# Pull check
read -p "Would you like to pull first? " varpull
if [[ "$varpull" == "y" ]]; then
	cd $repository
	read -p "Remote shortname? Defaults to origin" varremote
	if [ -z "$varremote" ]; then
		varremote="origin"
		echo
	fi
	read -p "Branch? " varbranch
	git pull "$varremote" "$varbranch"
else 
	echo	
fi

# Poll-time check
if [ -z "$polltime" ]; then
	echo "Another quick Q:"
	read -p "How frequently would like to poll git status? Default will be set to 30 seconds: " polltime
	if [ -z "$polltime" ]; then
		echo "Ah, the classics."
		polltime="30s"
		echo
	fi
fi

# Main body, a simple and effective inifinite while loop.
while :
do
	mainloop	
done
