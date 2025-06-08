#!/usr/bin/env bash

cd `git rev-parse --show-toplevel`
pyinstaller --onefile --noconfirm --clean --console --name=gsw gsw.py
cp ./dist/gsw ./gsw