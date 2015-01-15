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
RUN useradd docker -G wheel,root
USER docker
RUN bash -c 'bash <(curl aur.sh) -si --noconfirm --asroot package-query yaourt'
RUN yaourt -Suya
