# Arch Linux base docker container with AUR helper (paru or yay, default paru)
FROM archlinux/archlinux:base-devel as update-mirrors

# update mirrorlist
ADD https://raw.githubusercontent.com/greyltc/docker-archlinux/master/get-new-mirrors.sh /usr/bin/get-new-mirrors
RUN chmod +x /usr/bin/get-new-mirrors
RUN get-new-mirrors

from update-mirrors as build-helper-img
# probably is ab
ARG AUR_USER

# can be paru or yay
ARG HELPER

# install helper and add a user for it
ADD add-aur.sh /root
RUN bash /root/add-aur.sh "${AUR_USER}" "${HELPER}"

# now to install from the AUR, you might do something like this in your Dockerfile:
# RUN aur-install aur-package1 aur-package2 non-aur-package3
