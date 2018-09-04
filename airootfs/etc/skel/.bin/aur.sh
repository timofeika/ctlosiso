#!/usr/bin/env bash
# Install script aur pkg
# autor: Alex Creio https://cvc.hashbase.io/

packages=(
oh-my-zsh-git zsh-autosuggestions
ttf-clear-sans ttf-roboto-mono capitaine-cursors clipit-gtk3
caffeine-ng python-ewmh
sublime-text-dev timeshift engrampa-thunar-gtk2 fsearch-git
obmenu-generator perl-linux-desktopfiles
xsettingsd qgnomeplatform-git skippy-xd-git betterlockscreen xfce-polkit-git
obkey-git tint2-git
)

for pack in "${packages[@]}"; do
    yay --noconfirm --needed -Sy "$pack"
done

echo "Aur pkg install Complete"