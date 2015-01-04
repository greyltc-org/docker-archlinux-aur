# Arch Linux base docker container
# with base-devel group and yaourt installed
FROM l3iggs/archlinux

# update pacman db
RUN pacman -Suy --noconfirm

# setup yaourt
RUN pacman -Suy --noconfirm --needed base-devel
RUN bash -c 'bash <(curl aur.sh) -si --noconfirm --asroot package-query yaourt'
RUN yaourt -Suya
