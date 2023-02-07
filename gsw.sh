#!/bin/bash
# gsw - ᚫᚻ - Alex Haskins, 2023, under the MIT License. Go nuts with this code, fam. 
# simple bash HUD for polling git status/logs, automating the basic aspects of the git workflow

function gswverinfo() {
    echo "v 1.2.3"
    exit 0
}

function gitpush() {
    echo
    git add . # . grabs recursively & * ignores .hiddenfile; therefore, "git add ."
    read -p "What's your commit message? " varmsg
    git commit -m "$varmsg"
    read -p "Shortname? Defaults to origin: " varremote
    if [ -z "$varremote" ]; then
        varremote="origin"
    fi
    read -p "Branch? Defaults to main: " varbranch
    if [ -z "$varbranch" ]; then
        varbranch="main"
    fi
    git push "$varremote" "$varbranch"
}

function gitrem() {
    echo
    read -p "What file would you like to remove? " vargitrm
    git rm "$vargitrm"
}

function gitign() {
    echo
    read -p "What file would you like to add to .gitignore? " varignore
    echo "$varignore" >> $repository/.gitignore
}

function gitpull () {
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
}

function helpme() {
	echo "gsw - Git Status Watch(er)"
	echo 
	echo "usage: gsw [-t X] [-r filepath] [-v]"	
	echo "  -t <int> time in seconds (default 10 seconds)"
	echo "  -r <filepath> repository directory, relative or absolute are fine (default cwd)"
	echo "  -v (shows version)"
	echo
	echo "Keep track of changes to your repo - live, local, and latebreaking."
	exit 0
}

function exitpoll() {
    read -p "Would you like to exit [x] or continue [anything else]? " varcont
    echo
    if [ "$varcont" = "x" ]; then
        echo "Thanks for coding with us! Hope it helped!"
        exit 0
    else
        echo "Let's go!!"
        sleep 2
        echo "ᚫᚻ"
        clear
        mainloop
    fi
}

function initsequence() {
    if [ -z "$repository" ]; then
        repository=$(pwd) # if argument was blank, default to cwd
    fi
    cd $repository # Go there.
    varisgit=$(find . -maxdepth 1 -mindepth 1 -type d -name ".git") #find the .git folder, proving its a repo.
    if [ -z "$varisgit" ]; then
        echo "No git repository found in the current/specified directory. Try again."
        exit 1
    fi
    if [ -z "$polltime" ]; then # Poll-time check; default 10 seconds. Old versions used 30s - was too long & caused confusion
        polltime="10"
    fi
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
        echo echo "ᚫᚻ"
    fi
}

function mainloop() {
	# Build (strong air quote) UI
	echo "Git Status Watch (gsw) - a terminal HUD for your repos."
	echo "-------------------------------------------------------------"
	echo "* You're currently watching $(pwd) $(git branch)."
	echo
	echo "Logs:"
	echo "-------------------------------------------------------------"
	git log --graph -n 5 --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
	echo
	echo "Status:"
	echo "-------------------------------------------------------------"
	git status
	echo
	# That was the output, now for the input portion of the HUD
	echo "Options: [p] pull; [c] commit; [r] remove; [i] gitignore; [x] exit"
	read -t $polltime -n 1 -p "What would you like to do? " varcommit
	case "$varcommit" in
        "p") gitpull;;
        "c") gitpush;;
        "r") gitrem;;
        "i") gitign;;
        "x") exitpoll;;
        *) clear;;
    esac
}

#############################################################################################
## START - hilariously late in the script to begin, but required definitions are required. ##
#############################################################################################


while getopts "hvtr:" flag
do
    case "${flag}" in
        h) helpme ;;
        v) gswverinfo ;;
        t) polltime=${OPTARG};; 
        r) repository=${OPTARG};;
    esac
done

clear
echo "Welcome to Git Status Watch (gsw), a terminal HUD for your repos."
sleep 2
initsequence
clear
while : # It's always true, so it always loops!
do
	mainloop
done
