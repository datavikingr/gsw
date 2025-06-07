#!/usr/bin/env bash

pyinstaller --onefile --noconfirm --clean --console --name=gsw gsw.py
cp ./dist/gsw ./gsw