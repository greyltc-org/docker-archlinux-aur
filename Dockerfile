# Arch Linux base docker container
# with base-devel group and yaourt installed for aur access
FROM l3iggs/archlinux

# update pacman db
RUN pacman -Suy --noconfirm

# install development packages
RUN pacman -Suy --noconfirm --needed base-devel

# here is some garbage to work around the fact that makepkg's --asroot was removed by the stupid devs
RUN pacman -Suy --noconfirm --needed sudo
RUN sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
RUN useradd aur-builder -G wheel,root
USER aur-builder
WORKDIR /tmp
RUN bash <(curl aur.sh) -si --noconfirm package-query yaourt)
RUN yaourt -Suya
USER 0
WORKDIR /

# to install packages from the AUR using yaourt, you must switch to user "aur-builder" using docker's USER command
