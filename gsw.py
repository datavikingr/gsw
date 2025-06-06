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
    curses.init_pair(1, curses.COLOR_BLUE, -1)
    curses.init_pair(2, curses.COLOR_GREEN, -1)
    curses.init_pair(3, curses.COLOR_RED, -1)
    curses.init_pair(4, curses.COLOR_YELLOW, -1)
    curses.init_pair(5, curses.COLOR_CYAN, -1)
    curses.init_pair(6, curses.COLOR_MAGENTA, -1)
    curses.init_pair(7, curses.COLOR_WHITE, -1)
    curses.init_pair(8, curses.COLOR_BLACK, curses.COLOR_WHITE)

def draw_box(stdscr, y, h, w, label=""):
    stdscr.attron(curses.color_pair(7))
    stdscr.addstr(y, 0, "┌" + "─" * (w - 2) + "┐")
    for i in range(1, h - 1):
        stdscr.addstr(y + i, 0, "│" + " " * (w - 2) + "│")
    stdscr.addstr(y + h - 1, 0, "└" + "─" * (w - 2) + "┘")
    if label:
        stdscr.addstr(y, 2, f" {label} ")
    stdscr.attroff(curses.color_pair(7))

def draw_main(stdscr, repo_path, log_count):
    stdscr.clear()
    curses.curs_set(0)
    os.chdir(repo_path)
    branch = get_current_branch()
    now = datetime.now().strftime("%H:%M")
    width = curses.COLS
    height = curses.LINES

    # Header panel


    # Top panel with repo, branch, and time
    title_left = "GSW"
    title_right = now
    title_center = f"{repo_path} * {branch}"
    spacer = " " * int(max(0, width - len(title_left) - len(title_center) - len(title_right) - 6)/2)
    header = f" {title_left} {spacer} {title_center} {spacer} {title_right} "
    stdscr.attron(curses.color_pair(7))
    stdscr.addstr(0, 0, header[:width])
    stdscr.attroff(curses.color_pair(7))

    # Logs panel
    log_box_height = log_count + 4
    draw_box(stdscr, 2, log_box_height, width, "Logs")
    log_output = run_cmd(f"git log --graph -n {log_count} --pretty=format:'<%an> - %s (%cr)' --abbrev-commit")
    for idx, line in enumerate(log_output.splitlines()):
        stdscr.addstr(3 + idx, 2, line[:width - 4], curses.color_pair(5))

    # Status panel
    status_output = run_cmd("git status")
    status_lines = status_output.splitlines()
    status_box_y = 2 + log_box_height + 1
    status_box_height = len(status_lines) + 3
    draw_box(stdscr, status_box_y, status_box_height, width, "Status")
    for idx, line in enumerate(status_lines):
        color = curses.color_pair(2) if "modified" in line else 0
        stdscr.addstr(status_box_y + 1 + idx, 2, line[:width - 4], color)

    # Menu panel
    menu_y = height - 5
    draw_box(stdscr, menu_y, 4, width, "Menu")
    stdscr.addstr(menu_y + 1, 2, "Basic:  [a] add  [c] commit  [p] pull  [h] push  [r] remove  [i] ignore  [x] exit", curses.color_pair(4))
    stdscr.addstr(menu_y + 2, 2, "Branch: [n] new  [s] switch  [m] merge  [d] delete  [u] push branch", curses.color_pair(4))

    stdscr.refresh()

def prompt(stdscr, prompt_str):
    curses.echo()
    stdscr.nodelay(False)  # Pause auto-refresh and key polling
    stdscr.move(curses.LINES - 1, 0)
    stdscr.clrtoeol()
    stdscr.attron(curses.color_pair(6))
    stdscr.addstr(curses.LINES - 1, 0, prompt_str)
    stdscr.attroff(curses.color_pair(6))
    stdscr.refresh()
    try:
        input_str = stdscr.getstr().decode()
    except:
        input_str = ""
    curses.noecho()
    stdscr.nodelay(True)  # Resume polling
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
