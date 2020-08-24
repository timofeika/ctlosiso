#!/bin/bash

set -e

rm -rf {work,out}
pacman -Scc --noconfirm --quiet
rm -rf /var/cache/pacman/pkg/*
pacman -Syy --quiet
