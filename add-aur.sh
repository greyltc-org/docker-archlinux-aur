#!/usr/bin/env bash
# this script takes two arguments and sets up unattended AUR access for user ${1} via a helper, ${2}
set -o pipefail
set -o errexit
set -o nounset
set -o verbose
set -o xtrace

AUR_USER="${1:-ab}"
HELPER="${2:-yay}"

# we're gonna need sudo to build as the AUR user we're about to set up
pacman -Syu sudo --needed --noprogressbar --noconfirm

# create the user
useradd "${AUR_USER}" --system --shell /usr/bin/nologin --create-home --home-dir "/var/${AUR_USER}"

# lock out the ${AUR_USER}'s password
passwd --lock "${AUR_USER}"

# give the aur user passwordless sudo powers for pacman
echo "${AUR_USER} ALL=(ALL) NOPASSWD: /usr/bin/pacman" > "/etc/sudoers.d/allow_${AUR_USER}_to_pacman"

# let root cd with sudo
echo "root ALL=(ALL) CWD=* ALL" > /etc/sudoers.d/permissive_root_Chdir_Spec

# use all possible cores for subsequent package builds
sed 's,^#MAKEFLAGS=.*,MAKEFLAGS="-j$(nproc)",g' -i /etc/makepkg.conf

# don't compress the packages built here
sed "s,^PKGEXT=.*,PKGEXT='.pkg.tar',g" -i /etc/makepkg.conf

# get helper pkgbuild
sudo -u "${AUR_USER}" -D~ bash -c "curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/${HELPER}.tar.gz"
sudo -u "${AUR_USER}" -D~ bash -c "bsdtar -xvf ${HELPER}.tar.gz"
sudo -u "${AUR_USER}" -D~ bash -c "rm ${HELPER}.tar.gz"

# make helper
sudo -u "${AUR_USER}" -D~//${HELPER} bash -c "makepkg -s --noprogressbar --noconfirm --needed"

# install helper
pacman -U "/var/${AUR_USER}/${HELPER}"/*.pkg.tar --noprogressbar --noconfirm
rm -rf "/var/${AUR_USER}/${HELPER}"

# this must be a bug in yay's PKGBUILD...
rm -rf "/var/${AUR_USER}/.cache/go-build"

# chuck deps
pacman -Qtdq | pacman -Rns - --noconfirm

# setup storage for AUR packages built in the future
sed -i '/PKGDEST=/c\PKGDEST=/var/cache/makepkg/pkg' -i /etc/makepkg.conf
mkdir -p /var/cache/makepkg
install -o "${AUR_USER}" -d /var/cache/makepkg/pkg

if [ "${HELPER}" == "yay" ] || [ "${HELPER}" == "paru" ]
then
  # do a helper system update just to ensure the helper is working
  sudo -u "${AUR_USER}" -D~ bash -c "${HELPER} -Syu --noprogressbar --noconfirm --needed"

  # cache clean
  sudo -u "${AUR_USER}" -D~ bash -c "yes | ${HELPER} -Scc"
  
  echo "Packages from the AUR can now be installed like this:"
  echo "sudo -u ${AUR_USER} -D~ bash -c '${HELPER} -Syu --needed --removemake --noprogressbar --noconfirm PACKAGE'"
fi
