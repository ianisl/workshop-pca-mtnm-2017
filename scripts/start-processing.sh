#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dir="$(dirname "$dir")"

processing-java  --force --sketch="$dir" --output="$dir/build-tmp" --run
