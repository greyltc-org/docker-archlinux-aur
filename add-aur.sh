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
curl --silent --location https://raw.githubusercontent.com/greyltc/docker-archlinux/master/get-new-mirrors.sh > /tmp/get-new-mirrors
chmod +x /tmp/get-new-mirrors
mv /tmp/get-new-mirrors /bin/.
get-new-mirrors

# we're gonna need sudo to use the helper properly
yes | pacman -S --needed --noprogressbar sudo || echo "Nothing to do"

# create the user
AUR_USER_HOME="/var/${AUR_USER}"
useradd "${AUR_USER}" --system --shell /usr/bin/nologin --create-home --home-dir "${AUR_USER_HOME}"

# lock out the AUR_USER's password
passwd --lock "${AUR_USER}"

# give the aur user passwordless sudo powers for pacman
echo "${AUR_USER} ALL=(ALL) NOPASSWD: /usr/bin/pacman" > "/etc/sudoers.d/allow_${AUR_USER}_to_pacman"

# let root cd with sudo
echo "root ALL=(ALL) CWD=* ALL" > /etc/sudoers.d/permissive_root_Chdir_Spec

# build config setup
sudo -u ${AUR_USER} -D~ bash -c 'mkdir -p .config/pacman'

# use all possible cores for builds
sudo -u ${AUR_USER} -D~ bash -c 'echo MAKEFLAGS="-j\$(nproc)" > .config/pacman/makepkg.conf'

# don't compress the packages built here
#sudo -u ${AUR_USER} -D~ bash -c 'echo PKGEXT=".pkg.tar" >> .config/pacman/makepkg.conf'

# setup storage for AUR packages built
NEW_PKGDEST="/home/custompkgs"
mkdir -p "$(dirname \"${_pkgdest}\")"
install -o "${AUR_USER}" -d "${NEW_PKGDEST}"
sudo -u ${AUR_USER} -D~ bash -c "echo \"PKGDEST=${NEW_PKGDEST}\" >> .config/pacman/makepkg.conf"

# get helper pkgbuild
sudo -u "${AUR_USER}" -D~ bash -c "curl --silent --location https://aur.archlinux.org/cgit/aur.git/snapshot/${HELPER}.tar.gz | bsdtar -xvf -"

# make helper
sudo -u "${AUR_USER}" -D~//${HELPER} bash -c "yes | makepkg -s --noprogressbar --needed"

# install helper
yes | pacman -U "${NEW_PKGDEST}"/*.pkg.* --noprogressbar

# cleanup
rm -rf "${AUR_USER_HOME}/${HELPER}"
rm -rf "${AUR_USER_HOME}/.cache/go-build"
rm -rf "${AUR_USER_HOME}/.cargo"

# chuck deps
yes | pacman -Rns $(pacman -Qtdq) || echo "Nothing to remove"

tee /bin/aur-install <<EOF
#!/bin/sh
if test ! -z "\$@"
then
  if test "${HELPER}" = paru
  then
    sudo -u ${AUR_USER} -D~ bash -c 'yes | paru -S --removemake --needed --noprogressbar "\$@"' true "\$@"
    if test ! -z \${PKG_OUT+x}
    then
      sudo mkdir -p "\${PKG_OUT}"
      sudo mv -f "${NEW_PKGDEST}"/* "\${PKG_OUT}" || :
    fi
  else
    sudo -u ${AUR_USER} -D~ bash -c 'yes | ${HELPER} -S --needed --noprogressbar "\$@"' true "\$@"
  fi
else
  echo "Nothing to install"
fi

# cache clean
if test "${HELPER}" = paru
then
  DELETE_OPT="d"
else
  DELETE_OPT=""
fi
sudo -u "${AUR_USER}" -D~ bash -c "yes | ${HELPER} -Scc\${DELETE_OPT} >/dev/null 2>&1"
EOF
chmod +x /bin/aur-install

if test "${HELPER}" = yay || test "${HELPER}" = paru
then
  /bin/aur-install ${HELPER}

  echo "Packages from the AUR can now be installed like this:"
  echo "aur-install package-number-one package-number-two" 
fi
