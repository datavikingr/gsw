#!/usr/bin/env python

import curses
import subprocess
import argparse
import os
import time
from datetime import datetime


def run_cmd(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True).stdout.strip()

def get_current_branch():
    return run_cmd("git branch --show-current")

def init_colors():
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_BLUE, -1)    # Blue
    curses.init_pair(2, curses.COLOR_GREEN, -1)   # Green
    curses.init_pair(3, curses.COLOR_RED, -1)     # Red
    curses.init_pair(4, curses.COLOR_YELLOW, -1)  # Yellow
    curses.init_pair(5, curses.COLOR_CYAN, -1)    # Cyan
    curses.init_pair(6, curses.COLOR_MAGENTA, -1) # Magenta
    curses.init_pair(7, curses.COLOR_WHITE, -1)   # Header text

def draw_main(stdscr, repo_path, log_count):
    stdscr.clear()
    curses.curs_set(0)

    os.chdir(repo_path)
    branch = get_current_branch()
    now = datetime.now().strftime("%H:%M")

    # Top panel with repo, branch, and time
    width = curses.COLS
    title_left = "GSW"
    title_right = now
    title_center = f"{repo_path} * {branch}"
    spacer = " " * int(max(0, width - len(title_left) - len(title_center) - len(title_right) - 6)/2)
    header = f" {title_left} {spacer} {title_center} {spacer} {title_right} "
    stdscr.addstr(0, 0, header[:width], curses.color_pair(7) )

    stdscr.addstr(2, 0, "Logs:", curses.A_UNDERLINE)
    stdscr.addstr(3, 0, "-------------------------------------------------------------")
    log_output = run_cmd(f"git log --graph -n {log_count} --pretty=format:'<%an> - %s (%cr)' --abbrev-commit")
    for idx, line in enumerate(log_output.splitlines()):
        stdscr.addstr(4 + idx, 0, line, curses.color_pair(5))

    y = 4 + len(log_output.splitlines()) + 1
    stdscr.addstr(y, 0, "Status:", curses.A_UNDERLINE)
    stdscr.addstr(y + 1, 0, "-------------------------------------------------------------")
    status_output = run_cmd("git status")
    for idx, line in enumerate(status_output.splitlines()):
        stdscr.addstr(y + 2 + idx, 0, line, curses.color_pair(2) if "modified" in line else 0)

    # Bottom menu panel
    menu_y = curses.LINES - 3
    stdscr.addstr(menu_y, 0, "Basic Options:  [a] add  [c] commit  [p] pull  [h] push  [r] remove  [i] ignore  [x] exit", curses.color_pair(4))
    stdscr.addstr(menu_y + 1, 0, "Branch Options: [n] new  [s] switch  [m] merge  [d] delete  [u] push branch", curses.color_pair(4))
    stdscr.refresh()

def prompt(stdscr, prompt_str):
    curses.echo()
    stdscr.addstr(curses.LINES - 1, 0, prompt_str)
    stdscr.clrtoeol()
    stdscr.refresh()
    input_str = stdscr.getstr().decode()
    curses.noecho()
    return input_str

def main(stdscr, args):
    init_colors()
    repo_path = os.path.abspath(args.repository or os.getcwd())
    log_count = args.logs
    polltime = args.polltime

    if not os.path.isdir(os.path.join(repo_path, ".git")):
        stdscr.addstr(0, 0, "Not a valid Git repository.", curses.color_pair(3))
        stdscr.refresh()
        time.sleep(2)
        return

    stdscr.nodelay(True)
    last_refresh = 0

    while True:
        now = time.monotonic()
        if now - last_refresh >= polltime:
            draw_main(stdscr, repo_path, log_count)
            last_refresh = now

        try:
            key = stdscr.getkey()
        except:
            time.sleep(0.1)
            continue

        if key == 'x':
            break
        elif key == 'a':
            run_cmd("git add .")
        elif key == 'p':
            remote = prompt(stdscr, "Remote [origin]: ") or "origin"
            branch = prompt(stdscr, "Branch [main]: ") or "main"
            run_cmd(f"git pull {remote} {branch}")
        elif key == 'c':
            run_cmd("git add .")
            msg = prompt(stdscr, "Commit message [bug fixes]: ") or "bug fixes"
            run_cmd(f"git commit -m \"{msg}\"")
        elif key == 'h':
            remote = prompt(stdscr, "Remote [origin]: ") or "origin"
            branch = prompt(stdscr, "Branch [main]: ") or "main"
            run_cmd(f"git push {remote} {branch}")
        elif key == 'r':
            file = prompt(stdscr, "File to remove: ")
            if file:
                run_cmd(f"git rm {file}")
        elif key == 'i':
            file = prompt(stdscr, "File to ignore: ")
            if file:
                with open(os.path.join(repo_path, ".gitignore"), "a") as f:
                    f.write(file + "\n")
        elif key == 'n':
            branch = prompt(stdscr, "New branch name: ")
            if branch:
                run_cmd(f"git checkout -b {branch}")
        elif key == 's':
            run_cmd("git branch")
            branch = prompt(stdscr, "Switch to branch: ")
            if branch:
                run_cmd(f"git checkout {branch}")
        elif key == 'm':
            source = prompt(stdscr, "Source branch: ")
            target = prompt(stdscr, "Target branch: ")
            if source and target:
                run_cmd(f"git checkout {target}")
                run_cmd(f"git merge {source}")
        elif key == 'd':
            branch = prompt(stdscr, "Branch to delete: ")
            if branch:
                run_cmd(f"git branch -d {branch}")
        elif key == 'u':
            branch = get_current_branch()
            remote = prompt(stdscr, f"Remote [origin] to push {branch}: ") or "origin"
            run_cmd(f"git push {remote} {branch}")

        draw_main(stdscr, repo_path, log_count)
        last_refresh = time.monotonic()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Git Status Watch")
    parser.add_argument("-t", "--polltime", type=int, default=10, help="Refresh rate in seconds")
    parser.add_argument("-r", "--repository", help="Repository path")
    parser.add_argument("-l", "--logs", type=int, default=5, help="Number of log entries to show")
    parser.add_argument("-v", "--version", action="version", version="gsw 2.0")
    args = parser.parse_args()

    curses.wrapper(main, args)
