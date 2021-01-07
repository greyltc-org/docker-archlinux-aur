#!/usr/bin/env bash
# this script sets up unattended aur access via yay for a user given as the first argument
set -o pipefail -e

if test -z "$1"
then
   echo "You must specify a user name"
   exit -1
fi

AUR_USER=$1

# install yay deps
pacman -Syyu git sudo pacman go --needed --noprogressbar --noconfirm

# create the user
useradd -m $AUR_USER

# set the user's password to blank
echo "${AUR_USER}:" | chpasswd -e

# give the aur user passwordless sudo powers
echo "$AUR_USER      ALL = NOPASSWD: ALL" >> /etc/sudoers

# use all possible cores for subsequent package builds
sed -i 's,^#MAKEFLAGS=.*,MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf

# don't compress the packages built here
sed -i "s,^PKGEXT=.*,PKGEXT='.pkg.tar',g" /etc/makepkg.conf

# install yay
su $AUR_USER -c 'cd; git clone https://aur.archlinux.org/yay.git'
su $AUR_USER -c 'cd; cd yay; makepkg'
pushd /home/$AUR_USER/yay/
pacman -U *.pkg.tar --noprogressbar --noconfirm
popd
rm -rf /home/$AUR_USER/yay

# this must be a bug in yay's PKGBUILD...
rm -rf /home/$AUR_USER/.cache/go-build
# go clean -cache  # alternative cache clean 

# chuck go
pacman -Rs go --noconfirm

# do a yay system update just to ensure yay is working
su $AUR_USER -c 'yay -Syyu --noprogressbar --noconfirm --needed'

# cache clean
su $AUR_USER -c 'yes | yay -Scc'

echo "Packages from the AUR can now be installed like this:"
echo "su $AUR_USER -c 'yay -S --needed --noprogressbar --noconfirm PACKAGE'"
