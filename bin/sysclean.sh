#!/usr/bin/env bash

find ~/ -type f \( -name ".DS_Store" -o -name ".localized" \) -exec rm -f {} \;
