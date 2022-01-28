#!/usr/bin/env bash
# this script takes two arguments and sets up unattended AUR access for user ${1} via a helper, ${2}
set -o pipefail
set -o errexit
set -o nounset
set -o verbose
set -o xtrace

# debugging
printenv

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
sudo -u "${AUR_USER}" -D~ bash -c "curl -s -L https://aur.archlinux.org/cgit/aur.git/snapshot/${HELPER}.tar.gz | bsdtar -xvf -"

# make helper
sudo -u "${AUR_USER}" -D~//${HELPER} bash -c "makepkg -s --noprogressbar --noconfirm --needed"

# install helper
pacman -U "/var/${AUR_USER}/${HELPER}"/*.pkg.tar --noprogressbar --noconfirm
rm -rf "/var/${AUR_USER}/${HELPER}"

# _not_ a fan of a makepkg build leaving garbage in ${HOME}
rm -rf "/var/${AUR_USER}/.cache/go-build"
rm -rf "/var/${AUR_USER}/.cargo"

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
  if test "${HELPER}" == paru
  then
    sudo -u "${AUR_USER}" -D~ bash -c "yes | paru -Sc --delete; yes | paru -cc"
  else
    sudo -u "${AUR_USER}" -D~ bash -c "yes | ${HELPER} -Scc"
  fi
  yes | pacman -Scc

  echo "Packages from the AUR can now be installed like this:"
  echo "aur-install package-number-one package-number-two" 
fi

tee /bin/aur-install <<EOF
#!/bin/sh
if test "${HELPER}" == paru
then
  sudo -u ${AUR_USER} -D~ bash -c 'paru -Syu --removemake --needed --noprogressbar --noconfirm "\$@"; yes|paru -Sc --delete>/dev/null 2>&1; yes | paru -cc>/dev/null 2>&1' true "\$@"
else
  sudo -u ${AUR_USER} -D~ bash -c '${HELPER} -Syu --needed --noprogressbar --noconfirm "\$@"' true "\$@"
fi
yes | pacman -Scc >/dev/null 2>&1
EOF
chmod +x /bin/aur-install

# same as aur-install helper above, but with no cleanup of the built package
tee /bin/aur-install-dirty <<EOF
#!/bin/sh
if test "${HELPER}" == paru
then
  sudo -u ${AUR_USER} -D~ bash -c 'paru -Syu  --removemake --needed --noprogressbar --noconfirm "\$@"; yes | paru -cc >/dev/null 2>&1; yes | pacman -Scc>/dev/null 2>&1' true "\$@"
  yes | paru -cc >/dev/null 2>&1
else
  sudo -u ${AUR_USER} -D~ bash -c '${HELPER} -Syu  --needed --noprogressbar --noconfirm "\$@"' true "\$@"
fi
yes | pacman -Scc >/dev/null 2>&1
EOF
chmod +x /bin/aur-install-dirty
