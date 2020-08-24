#!/bin/bash

reflector -a 12 -f10 -l 70 -f 20 -p https -p http --sort rate --save /etc/pacman.d/mirrorlist

# check_country=$(curl -s https://ipinfo.io/country)
