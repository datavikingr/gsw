#!/bin/bash
# gsw - ᚫᚻ - Alex Haskins, 2023, under the MIT License. Go nuts with this code, fam. 
# simple bash HUD for polling git status/logs, automating the basic aspects of the git workflow

function gswverinfo() {
    echo "v 2.0"
    exit 0
}

function helpme() {
	echo "gsw - Git Status Watch v 1.2.4"
	echo 
	echo "usage: gsw [-t X] [-r filepath] [-l X] [-v]"	
	echo "  -t <int> refresh rate in seconds (default 10 seconds)"
	echo "  -r <filepath> repository directory, relative or absolute are fine (default cwd)"
	echo "  -l <int> number of log entries to display (default 3)"
	echo "  -v (shows version)"
	echo
	echo "Keep track of changes to your repo - live, local, and latebreaking. Happy coding!"
	exit 0
}

function gitpull () {
    echo
    read -p "Remote shortname? Defaults to origin: " varremote
    if [ -z "$varremote" ]; then
        varremote="origin"
    fi
    echo
    read -p "Branch? Defaults to main: " varbranch
    if [ -z "$varbranch" ]; then
        varbranch="main"
    fi
    echo
    git pull "$varremote" "$varbranch"
    sleep 3
    clear
}

function gitcomm() {
    echo
    git add . 
    read -p "What's your commit message? Defaults to 'bug fixes': " varmsg
    if [ -z "$varmsg" ]; then
        varmsg="bug fixes"
    fi
    git commit -m "$varmsg"
    sleep 3
    clear
}

function gitpush() {
    echo
    read -p "Remote shortname? Defaults to origin: " varremote
    if [ -z "$varremote" ]; then
        varremote="origin"
    fi
    echo
    read -p "Branch? Defaults to main: " varbranch
    if [ -z "$varbranch" ]; then
        varbranch="main"
    fi
    git push "$varremote" "$varbranch"
    sleep 3
    clear
}

function gitrem() {
    echo
    read -p "What file would you like to remove? Empty cancels. " vargitrm
    if [ -z "$vargitrm" ]; then
        mainloop
    fi
    git rm "$vargitrm"
    sleep 3
    clear
}

function gitign() {
    echo
    read -p "What file would you like to add to .gitignore? Empty cancels. " varignore
    if [ -z "$varignore" ]; then
        mainloop
    fi
    touch $repository/.gitignore
    echo "$varignore" >> $repository/.gitignore
    sleep 3
    clear
}

function exitpoll() {
    echo
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

function branchnew() {
    echo
    read -p "New branch name? Empty cancels. " varnewbranch
    if [ -z "$varnewbranch" ]; then
        mainloop
    fi
    git checkout -b "$varnewbranch"
    sleep 3
    clear
}

function branchswitch() {
    echo
    git branch
    echo
    read -p "Switch to which branch? Empty cancels. " varswitchbranch
    if [ -z "$varswitchbranch" ]; then
        mainloop
    fi
    git checkout "$varswitchbranch"
    sleep 3
    clear
}

function branchmerge() {
    echo
    git branch
    echo
    read -p "Source branch for merge? Empty cancels. " varsourcebranch
    if [ -z "$varsourcebranch" ]; then
        mainloop
    fi
    echo
    read -p "Target branch for merge? Empty cancels. " vartargetbranch
    if [ -z "$vartargetbranch" ]; then
        mainloop
    fi
    git checkout "$vartargetbranch"
    git merge "$varsourcebranch"
    sleep 3
    clear
}

function branchdelete() {
    echo
    git branch
    echo
    read -p "Branch to delete? Empty cancels. " varkillbranch
    if [ -z "$varkillbranch" ]; then
        mainloop
    fi
    git branch -d "$varkillbranch"
    sleep 3
    clear
}    

function branchpush() {
    echo
    varpwbranch=$(git branch | grep '^\*' | awk '{print $2}')
    echo "Your current branch: $varpwbranch."
    gitpush
}


function mainloop() {
    # Build (strong air quote) UI
    varpwbranch=$(git branch | grep '^\*' | awk '{print $2}') #'p(rint)w(orking)branch', if that's more clear.
	echo "Git Status Watch (gsw) - a terminal HUD for your repos."
	echo "-------------------------------------------------------------"
	echo "* You're currently watching $(pwd) * $varpwbranch."
	echo
	echo "Logs:"
	echo "-------------------------------------------------------------"
	# git log --graph -n 3 --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
	git log --graph -n $logs --pretty=format:'%C(bold blue)<%an>%Creset - %s %Cgreen(%cr)' --abbrev-commit
	echo
	echo "Status:"
	echo "-------------------------------------------------------------"
	git status
	echo
	echo "Basic Options:  [p] pull; [c] add/commit; [h] push; [r] remove; [i] gitignore; [x] exit"
    echo "Branch Options: [n] new; [s] switch; [m] merge; [d] delete; [u] push branch"
	read -t $polltime -n 1 -p "What would you like to do? " varcommit
	case "$varcommit" in
        "p") gitpull;;
        "c") gitcomm;;
        "h") gitpush;;
        "r") gitrem;;
        "i") gitign;;
        "x") exitpoll;;
        "n") branchnew;;
        "s") branchswitch;;
        "m") branchmerge;;
        "d") branchdelete;;
        "u") branchpush;;
        *) clear;;
    esac
}

#############################################################################################
## START - hilariously late in the script to begin, but required definitions are required. ##
#############################################################################################

while getopts "hvtrl:" flag
do
    case "${flag}" in
        h) helpme ;;
        v) gswverinfo ;;
        t) polltime=${OPTARG};; 
        r) repository=${OPTARG};;
        l) logs=${OPTARG};;
    esac
done

clear
echo "Welcome to Git Status Watch (gsw), a terminal HUD for your repos."
sleep 2
if [ -z "$repository" ]; then
    repository=$(pwd) # if argument was blank, default to cwd
fi
cd $repository # Go there.
varisgit=$(find . -maxdepth 1 -mindepth 1 -type d -name ".git") #find the .git folder, proving its a repo.
if [ -z "$varisgit" ]; then
    echo "No git repository found in the current/specified directory. Try again."
    exit 1
fi
if [ -z "$polltime" ]; then # Poll-time check; default 10 seconds.
    polltime="10"
fi
if [ -z "$logs" ]; then
    logs="3" # if argument was blank, default to cwd
fi
clear
while : # It's always true, so it always loops!
do
	mainloop
done
