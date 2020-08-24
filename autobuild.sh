#!/bin/bash

# gpg --detach-sign Ctlos.iso
# gpg --verify ctlos.iso.sig ctlos.iso_name

user_name=st
iso_name=ctlos
iso_de=$1
iso_version=$2_$(date +%Y%m%d)

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

ISO="${iso_name}_${iso_de}_${iso_version}.iso"

#Build ISO File
build_iso(){
  package=archiso
  if pacman -Qs $package > /dev/null ; then
    echo "The package $package is installed"
  else
    echo "Installing package $package"
    pacman -S $package --noconfirm
  fi

  rm -rf /var/cache/pacman/pkg/*
  pacman-key --init
  pacman-key --populate

  source build.sh -v
}

#create md5sum, sha256, sig
check_sums() {
  chown -R $user_name out/
  cd out/
  echo "create MD5, SHA-256 Checksum, sig"
  sudo -u $user_name md5sum $ISO >> $ISO.md5.txt
  sudo -u $user_name shasum -a 256 $ISO >> $ISO.sha256.txt
  # sudo -u $user_name gpg --detach-sign --no-armor $ISO
}

run_qemu()
{
  qemu-system-x86_64 -m 2G -boot d -enable-kvm -cdrom $ISO
}

build_iso
check_sums
# run_qemu
