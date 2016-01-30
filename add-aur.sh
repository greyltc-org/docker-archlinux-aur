#!/usr/bin/env bash
# this script sets up unattended aur access via pacaur for a user given as the first argument
set -o pipefail -e

[[ -z "$1" ]] && echo "You must specify a user name" && exit 1
AUR_USER=$1

# create the user
useradd -m $AUR_USER

# setup gpg for this new user
su $AUR_USER -c 'gpg --refresh-keys'

# install devel packages
pacman -S --needed --noconfirm base-devel

# give the aur user passwordless sudo powers
echo "$AUR_USER      ALL = NOPASSWD: ALL" >> /etc/sudoers

# use all possible cores for subsequent package builds
sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf

# don't compress the packages built here
sed -i "s,PKGEXT='.pkg.tar.xz',PKGEXT='.pkg.tar',g" /etc/makepkg.conf

# install pacaur
su $AUR_USER -c 'cd; bash <(curl aur.sh) -si --noconfirm cower pacaur'
su $AUR_USER -c 'cd; rm -rf cower pacaur'

# do a pacaur system update
su $AUR_USER -c 'pacaur -Syyua --noedit --noconfirm'

echo "Packages from the AUR can now be installed like this:"
echo "su $AUR_USER -c 'pacaur -S --noedit --noconfirm PACKAGE'"
