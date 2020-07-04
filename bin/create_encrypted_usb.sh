#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo -e "Syntax: " $0 "<DRIVE>"
    echo -e "Example:" $0 "sdd1"
    exit 1
fi
DRIVE=$1
sudo cryptsetup luksFormat /dev/${DRIVE}
sudo cryptsetup luksOpen /dev/${DRIVE} ENCRYPT
sudo mkfs.ext4 /dev/mapper/ENCRYPT -L USB
sudo cryptsetup luksClose ENCRYPT
