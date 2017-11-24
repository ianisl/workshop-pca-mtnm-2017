#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dir="$(dirname "$dir")"
app="$(basename "$dir")"

pushd "$PWD"
cd "$dir"
cd ..
zip -r "$app"/dist/mtnm_workshop_4.zip ./"$app" -x "$app""/node_modules/*" -x "$app""/build-tmp/*" -x "$app""/.git/*" -x "$app""/_ Exports/*" -x "$app""/dist/*" -x "$app""/scripts/*" -x "*.swp" -x "$app""/.gitignore" -x "$app""/package.json" -x "$app""/package-lock.json" -x "$app""/gulpfile.js"
popd
