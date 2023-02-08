# gsw - git status watch v 2.0!!

gsw is a fully featured tui-based HUD for your git repos while you code. Think of it as similar to top/htop for git repo management. 

![image](https://user-images.githubusercontent.com/43792895/217566183-266466da-6e9b-4295-a710-0f4d9d9d21f2.png)

## Features:
- install.sh updates/installs globally or in user-land!
- status, logs, working directory, branch in HUD
- typical git workflow: add/commit, push, pull, rm, branch management, .gitignore
- Flag Arguments:
  - -t: customize refresh rate (default 10s)
  - -r: custom repo filepath path (default current directory)
  - -l: customize number of log entries in HUD (default 3)

## TODO:
- ~add git branch mechanics~
- ~add update check to gsw.sh~
- ~branch management~

## Install (or Update)
Navigate to your code directory (usually ~/src or ~/code).Then run:
```
git clone https://github.com/futurehaskins/gsw
./install.sh
```

That's it! Thanks for chosing gsw!!
