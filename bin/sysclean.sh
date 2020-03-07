#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
  find ~/ -type f \( -name ".DS_Store" -o name "._*" -o -name ".localized" \) -exec rm -f {} \;
  rm -rf ~/Library/Logs/*
  qlmanage -r cache
fi
