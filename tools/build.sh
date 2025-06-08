#!/usr/bin/env bash
# gsw - ᚫᚻ - Alex Haskins, 2025, under the MIT License. Go nuts with this code, fam. 
# build script for gsw; the even-lazier person's lazygit

# Only run this function if the script is executed directly,
# NOT if it is being sourced by another script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -e
    cd `git rev-parse --show-toplevel`
    #logging
    LOG_DATE=$(date +"%Y.%m.%d.%H.%M")
    LOG_NAME="build_${LOG_DATE}"
    mkdir -p "logs"
    exec > >(tee "logs/${LOG_NAME}.log") 2>&1
    #init
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    ROOT_DIR="$( dirname "$SCRIPT_DIR" )"
    cd "$ROOT_DIR"
    APP_NAME="gsw"
    VERSION_FILE="$ROOT_DIR/VERSION"
    CHANGELOG_FILE="$ROOT_DIR/changelog.txt"
    BUILD_DATE=$(date +"%Y-%m-%d_%H-%M")
    #versioning
    if [[ "$1" =~ ^--bump(=major|=minor|=patch)?$ ]]; then
        if [[ ! -f "$VERSION_FILE" ]]; then
            echo "VERSION file not found!"
            exit 1
        fi
        VERSION=$(cat "$VERSION_FILE")
        IFS='.' read -r major minor patch <<< "$VERSION"
        case "$1" in
            "--bump=major") ((major+=1)); minor=0; patch=0 ;;
            "--bump=minor") ((minor+=1)); patch=0 ;;
            "--bump"|"--bump=patch"|*) ((patch+=1)) ;;
        esac
        NEW_VERSION="$major.$minor.$patch"
        echo "$NEW_VERSION" > "$VERSION_FILE"
        echo "Version bumped to $NEW_VERSION"
        read -p "Changelog message: " changelog_msg
        echo "- $(date +"%Y-%m-%d %H:%M") - v$NEW_VERSION: $changelog_msg" >> "$CHANGELOG_FILE"
    fi
    #building
    echo "=== Building PyInstaller binary ==="
    cd `git rev-parse --show-toplevel`
    if [[ -z "$VIRTUAL_ENV" ]]; then
      source .venv/bin/activate
    fi
    pyinstaller --onefile --noconfirm --console --name=gsw gsw.py
    cp ./dist/gsw ./gsw
    ARCHIVE_NAME="$APP_NAME.$NEW_VERSION"
    cp ./gsw "./archive_builds/$ARCHIVE_NAME"
    echo "Build complete! Thanks for maintaining gsw!"
    echo "🎉 All builds complete! Distributables available in dist/"
    echo "Dumping this run's logs to git-tracked file: logs/most_recent.log."
    cat "logs/${LOG_NAME}.log" >> logs/most_recent.log
    #clean exit
    exit 0
fi