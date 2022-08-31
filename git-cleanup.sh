#!/usr/bin/env bash

rm -rf .git

git init -b default
git add .
git commit -m "Initial commit"

git remote add origin git@github.com:wkarasz/rescale-automation-scripts.git
git push -u --force origin default
