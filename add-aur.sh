#!/usr/bin/env bash
# this script sets up unattended aur access via yay for a user given as the first argument
set -o pipefail
set -o errexit
set -o nounset
set -o verbose
set -o xtrace

if test -z "$1"
then
   echo "You must specify a user name"
   exit -1
fi

AUR_USER="${1}"

# install yay deps
pacman -Syyu git sudo pacman go --needed --noprogressbar --noconfirm

# create the user
useradd ${AUR_USER} --system --shell /usr/bin/nologin --create-home --home-dir "/var/${AUR_USER}"

# lock out the ${AUR_USER}'s password
passwd --lock ${AUR_USER}

# give the aur user passwordless sudo powers for pacman
echo "${AUR_USER} ALL=(ALL) NOPASSWD: /usr/bin/pacman" > "/etc/sudoers.d/allow_${AUR_USER}_to_pacman"

# let root cd with sudo
echo "root ALL=(ALL) CWD=* ALL" > /etc/sudoers.d/permissive_root_Chdir_Spec

# use all possible cores for subsequent package builds
sed -i 's,^#MAKEFLAGS=.*,MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf

# don't compress the packages built here
sed -i "s,^PKGEXT=.*,PKGEXT='.pkg.tar',g" /etc/makepkg.conf

# install yay
sudo -u $AUR_USER -D~ bash -c "git clone https://aur.archlinux.org/yay.git"
sudo -u $AUR_USER -D~/yay bash -c "makepkg"
pushd /var/"${AUR_USER}"/yay
pacman -U *.pkg.tar --noprogressbar --noconfirm
popd
sudo -u $AUR_USER -D~ bash -c "rm -rf yay"

# this must be a bug in yay's PKGBUILD...
sudo -u $AUR_USER -D~ bash -c "rm -rf .cache/go-build"
# go clean -cache  # alternative cache clean 

# chuck go
pacman -Rs go --noconfirm

# do a yay system update just to ensure yay is working
sudo -u $AUR_USER -D~ bash -c "yay -Syyu --noprogressbar --noconfirm --needed"

# cache clean
sudo -u $AUR_USER -D~ bash -c "yes | yay -Scc"

echo "Packages from the AUR can now be installed like this:"
echo "sudo -u $AUR_USER -D~ bash -c 'yay -S --needed --noprogressbar --noconfirm PACKAGE'"
