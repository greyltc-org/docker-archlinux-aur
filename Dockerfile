# Arch Linux base docker container with pacaur for AUR access
FROM greyltc/archlinux
MAINTAINER Grey Christoforo <grey@christoforo.net>

# install development packages
RUN pacman -S --noconfirm --needed base-devel

# no sudo password for users in wheel group
RUN sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

# create docker user
RUN useradd -m -G wheel docker

# the default user is now "docker" and so commands requiring root permissions
# should be prefixed with sudo from now on
USER docker
WORKDIR /home/docker

# install pacaur
RUN gpg --keyserver pgp.mit.edu --recv-keys F56C0C53
RUN bash <(curl aur.sh) -si --noconfirm cower pacaur
RUN rm -rf cower pacaur

# do AUR upgrade once
RUN pacaur -Syyu --noedit --noconfirm
