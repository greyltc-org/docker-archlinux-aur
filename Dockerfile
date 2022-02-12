# Arch Linux base docker container with AUR helper (paru or yay, default paru)
FROM archlinux/archlinux:base-devel
LABEL maintainer="Greyson Christoforo <grey@christoforo.net>"
LABEL source="https://github.com/greyltc/docker-archlinux-aur"
LABEL org.opencontainers.image.source https://github.com/greyltc-org/docker-archlinux-aur

# probably is ab
ARG AUR_USER

# can be paru or yay
ARG HELPER

# update mirrorlist
ADD https://raw.githubusercontent.com/greyltc/docker-archlinux/master/get-new-mirrors.sh /tmp/get-new-mirrors
RUN bash /tmp/get-new-mirrors

# install helper and add a user for it
ADD add-aur.sh /root
RUN bash /root/add-aur.sh "${AUR_USER}" "${HELPER}"

# now to install from the AUR, you might do something like this in your Dockerfile:
# RUN aur-install aur-package1 aur-package2 non-aur-package3
