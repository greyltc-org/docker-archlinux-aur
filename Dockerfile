# Arch Linux base docker container with yay for AUR access
FROM archlinux:base-devel
LABEL maintainer="Greyson Christoforo <grey@christoforo.net>"
LABEL source="https://github.com/greyltc/docker-archlinux-aur"
LABEL org.opencontainers.image.source https://github.com/greyltc-org/docker-archlinux-aur

ARG AUR_USER
ARG HELPER

# install yay and add a user for it: ab
ADD add-aur.sh /root
RUN bash /root/add-aur.sh "${AUR_USER}" "${HELPER}"

# now to install from the AUR, you might do something like this in your dockerfile:
#RUN sudo -u ab -D~ bash -c 'yay -Syu --removemake --needed --noprogressbar --noconfirm PACKAGE'
