#!/usr/bin/env python

import curses
import subprocess
import argparse
import os
import time
from datetime import datetime

def run_cmd(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True).stdout.strip()

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
    curses.init_color(9,350,350,350)
    curses.init_pair(10, 9, -1)

def draw_box(stdscr, y, h, w, x=0, label=""):
    stdscr.attron(curses.color_pair(7))
    stdscr.addstr(y, x, "┌" + "─" * (w - 2) + "┐")
    for i in range(1, h - 1):
        stdscr.addstr(y + i, x, "│" + " " * (w - 2) + "│")
    stdscr.addstr(y + h - 1, x, "└" + "─" * (w - 2) + "┘")
    if label:
        stdscr.addstr(y, x + 2, f" {label} ")
    stdscr.attroff(curses.color_pair(7))

def draw_main(stdscr, repo_path, log_count):
    stdscr.clear()
    curses.curs_set(0)
    os.chdir(repo_path)
    branch = run_cmd("git branch --show-current")
    now = datetime.now().strftime("%H:%M")
    width = curses.COLS
    height = curses.LINES
    sidebar_width = 30
    main_width = width - sidebar_width - 2

    title_left = "GSW"
    title_right = now
    title_center = f"{repo_path} * {branch}"
    spacer = " " * int(max(0, width - len(title_left) - len(title_center) - len(title_right) - 6)/2)
    header = f" {title_left} {spacer} {title_center} {spacer} {title_right} "
    stdscr.attron(curses.color_pair(7))
    stdscr.addstr(0, 0, header[:width])
    stdscr.attroff(curses.color_pair(7))

    # Sidebar
    tree_output = run_cmd("tree -L 2 --dirsfirst --noreport --gitignore")
    tree_lines = tree_output.splitlines()
    tree_height = height - 2
    draw_box(stdscr, 1, tree_height, sidebar_width, 0, "Repo Tree")
    for idx, line in enumerate(tree_lines[:tree_height - 2]):
        stdscr.addstr(2 + idx, 2, line[:sidebar_width - 4], curses.color_pair(6))

    main_start_x = sidebar_width + 1 

    log_box_height = log_count + 2
    draw_box(stdscr, 1, log_box_height, main_width, main_start_x, "Logs")
    log_output = run_cmd(f"git log --graph -n {log_count} --pretty=format:'<%an> - %s (%cr)' --abbrev-commit")
    for idx, line in enumerate(log_output.splitlines()):
        stdscr.addstr(2 + idx, main_start_x + 2, line[:main_width - 4], curses.color_pair(5))

    status_output = run_cmd("git status")
    status_lines = status_output.splitlines()
    status_box_y = 1 + log_box_height
    status_box_height = 16
    draw_box(stdscr, status_box_y, status_box_height, main_width, main_start_x, "Status")

    untracked = False
    staged = False

    for idx, line in enumerate(status_lines):
        line_lower = line.lower().strip()

        if line_lower.startswith("changes to be committed"):
            staged = True
        elif line_lower.startswith("changes not staged for commit"):
            staged = False
        elif line_lower.startswith("untracked files"):
            untracked = True
        elif line_lower == "":
            staged = False
            untracked = False

        if untracked and line.startswith("\t"):
            color = curses.color_pair(3)  # Red
        elif line_lower.startswith("untracked files"):
            color = curses.color_pair(3)  # Red
        elif staged and line.startswith("\t"):
            color = curses.color_pair(2)  # Green
        elif line_lower.startswith("changes to be committed"):
            color = curses.color_pair(2)  # Green
        elif "modified:" in line:
            color = curses.color_pair(4)  # Yellow
        elif line_lower.startswith("changes not staged for commit"):
            color = curses.color_pair(4)  # Yellow
        else:
            color = curses.color_pair(7)  # Default (white)

        stdscr.addstr(status_box_y + 1 + idx, main_start_x + 2, line[:main_width - 4], color)

    menu_y = height - 5
    draw_box(stdscr, menu_y - 1 , 5, main_width, main_start_x, "Menu")
    stdscr.addstr(menu_y , main_start_x + 2, "Basic:  [f]etch  [p]ull  [a]dd  [r]emove  [c]ommit  pus[h]  [i]gnore  e[x]it", curses.color_pair(4))
    stdscr.addstr(menu_y + 1, main_start_x + 2, "Branch: [l]ist branches  [n]ew  [s]witch  [m]erge  [d]elete  p[u]sh branch", curses.color_pair(4))
    stdscr.addstr(menu_y + 2, main_start_x + 2, "Extra:  [z] stash  [y] pop  [b]lame [:] shell command", curses.color_pair(4))
    stdscr.refresh()

def show_pager(stdscr, title, lines):
    height, width = stdscr.getmaxyx()
    box_height = height - 4
    box_width = width - 10
    start_y = 2
    start_x = 5

    pos = 0
    max_pos = max(0, len(lines) - (box_height - 2))

    while True:
        stdscr.erase()
        draw_box(stdscr, start_y, box_height, box_width, start_x, title)

        visible_lines = lines[pos:pos + box_height - 2]
        for i, line in enumerate(visible_lines):
            truncated = line[:box_width - 4]
            stdscr.addstr(start_y + 1 + i, start_x + 2, truncated, curses.color_pair(7))

        stdscr.refresh()

        key = stdscr.getch()
        if key in [ord('q'), 27]:  # 'q' or Esc
            break
        elif key in [curses.KEY_DOWN, ord('j')]:
            pos = min(max_pos, pos + 1)
        elif key in [curses.KEY_UP, ord('k')]:
            pos = max(0, pos - 1)
        elif key in [curses.KEY_NPAGE]:  # Page down
            pos = min(max_pos, pos + (box_height - 2))
        elif key in [curses.KEY_PPAGE]:  # Page up
            pos = max(0, pos - (box_height - 2))

def small_prompt(stdscr, prompt_str):
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

def prompt(stdscr, prompt_str):
    curses.echo()
    stdscr.nodelay(False)
    height, width = stdscr.getmaxyx()
    box_height, box_width = 5, 76
    start_y = (height - box_height) // 2
    start_x = (width - box_width) // 2

    for y in range(height):
        for x in range(width):
            stdscr.chgat(y, x, 1, curses.color_pair(10))

    stdscr.attron(curses.color_pair(2))
    label = f"─ {prompt_str}─"
    filler = "─" * max(0, box_width - 2 - len(label))
    stdscr.addstr(start_y, start_x, f"┌{label}{filler}┐")
    for i in range(1, box_height - 1):
        stdscr.addstr(start_y + i, start_x, "│" + " " * (box_width - 2) + "│")
    stdscr.addstr(start_y + box_height - 1, start_x, "└" + "─" * (box_width - 2) + "┘")
    stdscr.attroff(curses.color_pair(2))

    stdscr.attron(curses.color_pair(7))
    stdscr.move(start_y + 2, start_x + 2)
    stdscr.attroff(curses.color_pair(7))

    stdscr.refresh()

    try:
        input_str = stdscr.getstr().decode()
    except:
        input_str = ""
    curses.noecho()
    stdscr.nodelay(True)
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
            branch = run_cmd("git branch --show-current")
            remote = prompt(stdscr, f"Remote [origin] to push {branch}: ") or "origin"
            run_cmd(f"git push {remote} {branch}")
        elif key == 'f':
            remote = prompt(stdscr, "Remote [origin]:") or "origin"
            run_cmd(f"git fetch {remote}")
        elif key == 'z':
            run_cmd("git stash push -m 'gsw auto-stash'")
        elif key == 'y':
            run_cmd("git stash pop")
        elif key == 'b':
            file = prompt(stdscr, "File to blame:")
            if file:
                output = run_cmd(f"git blame {file}")
                lines = output.splitlines()
                show_pager(stdscr, f"Blame: {file}", lines)
        elif key == 'l':
            output = run_cmd("git branch --sort=-committerdate")
            lines = output.splitlines()
            show_pager(stdscr, "Branches", lines)
        elif key == ':':
            command = small_prompt(stdscr, ":")
            custom_comm_output = run_cmd(command)
            lines = custom_comm_output.splitlines()
            show_pager(stdscr, command, lines)

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
