# Arch Linux base docker container
# with base-devel group and yaourt installed for aur access
FROM l3iggs/archlinux

# update pacman db
RUN pacman -Suy --noconfirm

# install development packages
RUN pacman -Suy --noconfirm --needed base-devel

# here is some garbage to work around the fact that makepkg's --asroot was removed
# no sudo password for users in wheel group
RUN sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

# create docker user
RUN useradd -m -G wheel docker
WORKDIR /home/docker

# install yaourt
RUN su -c "(bash <(curl aur.sh) -si --noconfirm package-query yaourt)" -s /bin/bash docker
USER docker
RUN sudo rm -rf /home/docker/*
RUN yaourt -Suya

# the default user is now "docker" and so commands requiring root permissions
# should be prefixed with sudo from now on
