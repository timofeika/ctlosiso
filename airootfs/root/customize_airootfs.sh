#!/usr/bin/env bash

set -e -u

isouser="liveuser"
OSNAME="ctlos"


localeGen() {
    sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
    sed -i "s/#\(ru_RU\.UTF-8\)/\1/" /etc/locale.gen
    locale-gen
}

setTimeZoneAndClock() {
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    hwclock --systohc --utc
}

editOrCreateConfigFiles() {
    # Locale
    echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
    echo "LC_COLLATE=C" >> /etc/locale.conf

    # Vconsole
    echo "KEYMAP=ru" > /etc/vconsole.conf
    echo "FONT=cyr-sun16" >> /etc/vconsole.conf

    # Hostname
    echo "$OSNAME" > /etc/hostname

    sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
    sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
}

fixPermissions() {
    #add missing /media directory
    mkdir -p /media
    chmod 755 -R /media

    #fix permissions
    chown root:root /
    chown root:root /etc
    chown root:root /etc/default
    chown root:root /usr
    chmod 755 /etc

    #enable sudo
    chmod 750 /etc/sudoers.d
    chmod 440 /etc/sudoers.d/g_wheel
    chown -R root /etc/sudoers.d
    chmod -R 755 /etc/sudoers.d
}

configRootUser() {
    usermod -s /usr/bin/zsh root
    chmod 700 /root
}

createLiveUser() {
    # add groups autologin and nopasswdlogin (for lightdm autologin)
    # groupadd -r autologin
    # groupadd -r nopasswdlogin

    ## add liveuser
    glist="audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel"
    if ! id $isouser 2>/dev/null; then
        useradd -m -g users -G $glist -s /bin/zsh $isouser
        passwd -d $isouser
        echo "$isouser ALL=(ALL) ALL" >> /etc/sudoers
    fi
}

setDefaults() {
    export _BROWSER=firefox
    echo "BROWSER=/usr/bin/${_BROWSER}" >> /etc/environment
    echo "BROWSER=/usr/bin/${_BROWSER}" >> /etc/profile

    export _EDITOR=nano
    echo "EDITOR=${_EDITOR}" >> /etc/environment
    echo "EDITOR=${_EDITOR}" >> /etc/profile

    echo "QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment
}

fontFix() {
    rm -rf /etc/fonts/conf.d/10-scale-bitmap-fonts.conf
}

fixWifi() {
    su -c 'echo "" >> /etc/NetworkManager/NetworkManager.conf'
    su -c 'echo "[device]" >> /etc/NetworkManager/NetworkManager.conf'
    su -c 'echo "wifi.scan-rand-mac-address=no" >> /etc/NetworkManager/NetworkManager.conf'
}

fixHibernate() {
    sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
    sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
    sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf
}

fixHaveged(){
    systemctl start haveged
    systemctl enable haveged

    rm -fr /etc/pacman.d/gnupg
}

# initkeys() {
#     pacman-key --init
#     # pacman-key --keyserver hkp://pool.sks-keyservers.net:80 --recv-keys 98F76D97B786E6A3
#     # pacman-key --keyserver hkps://hkps.pool.sks-keyservers.net:443 --recv-keys 98F76D97B786E6A3
#     pacman-key --keyserver keys.gnupg.net --recv-keys 98F76D97B786E6A3
#     pacman-key --lsign-key 98F76D97B786E6A3
#     pacman-key --populate archlinux
#     pacman-key --populate ctlos
#     pacman -Syy --noconfirm
# }

enableServices() {
    # systemctl enable pacman-init.service
    systemctl enable choose-mirror.service
    systemctl enable avahi-daemon.service
    systemctl enable vboxservice.service
    systemctl enable systemd-networkd.service
    systemctl enable systemd-resolved.service
    systemctl enable systemd-timesyncd
    systemctl enable sddm.service
    systemctl enable vbox-check.service
    systemctl enable xdg-user-dirs-update.service
    systemctl enable reflector.service
    # systemctl enable reflector.timer
    systemctl -fq enable NetworkManager.service
    systemctl mask systemd-rfkill@.service
    systemctl set-default graphical.target
}


localeGen
setTimeZoneAndClock
editOrCreateConfigFiles
fixPermissions
configRootUser
createLiveUser
setDefaults
fontFix
fixWifi
fixHibernate
fixHaveged
# initkeys
enableServices
