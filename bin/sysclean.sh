#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
  find ~/ -type f \( -name ".DS_Store" -o -name ".localized" \) -exec rm -f {} \;
  rm -rf ~/Library/Logs/*
fi
