#!/usr/bin/env bash

osascript -e 'tell application "iTerm" to activate'

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dir="$(dirname "$dir")"
dir="$(basename "$dir")"

osascript -e 'tell application "System Events"' -e 'set position of first window of application process "'"$dir"'" to {2320, 0}' -e 'end tell'
