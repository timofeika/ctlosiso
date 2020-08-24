#!/bin/bash

script_path=$(readlink -f ${0%/*})
# work_dir=${script_path}/work/x86_64/airootfs
work_dir=${script_path}/work/airootfs

chrooter(){
   arch-chroot ${work_dir} /bin/bash -c "${1}"
}

cat <<EOF >${work_dir}/settings.sh
pacman-key --init
## pacman-key --keyserver keys.gnupg.net --recv-keys 98F76D97B786E6A3
# pacman-key --add /usr/share/pacman/keyrings/ctlos.gpg
# pacman-key --recv-keys 50417293016B25BED7249D8398F76D97B786E6A3
# pacman-key --lsign-key 50417293016B25BED7249D8398F76D97B786E6A3
pacman-key --populate
# pacman-key --refresh-keys
reflector -a 12 -l 70 -f 30 -p https -p http --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy

# sed -i 's?GRUB_DISTRIBUTOR=.*?GRUB_DISTRIBUTOR=\"Ctlos\"?' /etc/default/grub
# sed -i 's?\#GRUB_THEME=.*?GRUB_THEME=\/boot\/grub\/themes\/crimson\/theme.txt?g' /etc/default/grub
# echo 'GRUB_DISABLE_SUBMENU=y' >> /etc/default/grub
# wget https://github.com/ctlos/install_sh/raw/master/cleaner.sh
# chmod +x cleaner.sh
# mv cleaner.sh /usr/bin/
EOF

echo "==== create settings.sh ===="

chmod +x ${work_dir}/settings.sh
chrooter /settings.sh
rm ${work_dir}/settings.sh
