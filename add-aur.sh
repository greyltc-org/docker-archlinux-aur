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

# update mirrorlist
curl --silent --location https://raw.githubusercontent.com/greyltc/docker-archlinux/master/get-new-mirrors.sh > /sbin/get-new-mirrors
chmod +x /sbin/get-new-mirrors
get-new-mirrors

# we're gonna need sudo to build as the AUR user we're about to set up
pacman -S sudo --needed --noprogressbar --noconfirm

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
pacman -Rns --noconfirm $(pacman -Qtdq) || echo "Nothing to remove"

# setup storage for AUR packages built
_pkgdest="/home/custompkgs"
mkdir -p "$(dirname \"${_pkgdest}\")"
install -o "${AUR_USER}" -d "${_pkgdest}"
sudo -u ${AUR_USER} -D~ bash -c "mkdir -p .config/pacman"
sudo -u ${AUR_USER} -D~ bash -c "echo \"PKGDEST=${_pkgdest}\" > .config/pacman/makepkg.conf"

tee /bin/aur-install <<EOF
#!/bin/sh
if test ! -z "\$@"
then
  if test "${HELPER}" == paru
  then
    sudo -u ${AUR_USER} -D~ bash -c 'paru -S --removemake --needed --noprogressbar --noconfirm "\$@"' true "\$@"
    if test ! -z \${PKG_OUT+x}
    then
      sudo mkdir -p "\${PKG_OUT}"
      sudo mv -f "${_pkgdest}"/* "\${PKG_OUT}" || :
    fi
  else
    sudo -u ${AUR_USER} -D~ bash -c '${HELPER} -S --needed --noprogressbar --noconfirm "\$@"' true "\$@"
  fi
else
  echo "Nothing to install"
fi

# cache clean
if test "${HELPER}" == paru
then
  sudo -u "${AUR_USER}" -D~ bash -c "yes | paru -Sc --delete >/dev/null 2>&1; yes | paru -cc >/dev/null 2>&1"
else
  sudo -u "${AUR_USER}" -D~ bash -c "yes | ${HELPER} -Scc >/dev/null 2>&1"
fi
sudo yes | pacman -Scc >/dev/null 2>&1 || :
EOF
chmod +x /bin/aur-install

if [ "${HELPER}" == "yay" ] || [ "${HELPER}" == "paru" ]
then
  /bin/aur-install ${HELPER}

  echo "Packages from the AUR can now be installed like this:"
  echo "aur-install package-number-one package-number-two" 
fi
