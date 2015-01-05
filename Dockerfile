# Arch Linux base docker container
# with base-devel group and yaourt installed for aur access
FROM l3iggs/archlinux

# update pacman db
RUN pacman -Suy --noconfirm

# setup yaourt
RUN pacman -Suy --noconfirm --needed base-devel
RUN echo "nobody ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /tmp
RUN su -c "(bash <(curl aur.sh) -si --noconfirm package-query yaourt)" -s /bin/bash nobody
RUN sed -i '/nobody ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers
RUN yaourt -Suya
WORKDIR /
