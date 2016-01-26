#!/usr/bin/env bash
# this script sets up unattended aur access via pacaur for a user given as the first argument
set -o pipefail -v

[[ -z "$1" ]] && echo "You ust specify a user name" && exit 1
AUR_USER=$1

# create the user
useradd -m $AUR_USER

# install devel packages
pacman -S --needed --noconfirm base-devel

# give the aur user passwordless sudo powers
echo "$AUR_USER      ALL = NOPASSWD: ALL" >> /etc/sudoers

# install pacaur
su $AUR_USER -c 'gpg --keyserver pgp.mit.edu --recv-keys F56C0C53'
su $AUR_USER -c 'cd; bash <(curl aur.sh) -si --noconfirm cower pacaur'
su $AUR_USER -c 'cd; rm -rf cower pacaur'

# do a pacaur system update
su $AUR_USER -c 'pacaur -Syyu --noedit --noconfirm'

