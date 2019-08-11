#!/usr/bin/env bash

for file in "${PWD}"/*; do
    if [[ -f "$file" ]] && [[ -x "$file" ]]; then
        echo Analyzing "$file" ...
        shellcheck -x "$file"
    fi
done
