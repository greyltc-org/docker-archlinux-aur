# Arch Linux base docker container with AUR helper (paru or yay, default paru)
FROM archlinux:base-devel
LABEL maintainer="Greyson Christoforo <grey@christoforo.net>"
LABEL source="https://github.com/greyltc/docker-archlinux-aur"
LABEL org.opencontainers.image.source https://github.com/greyltc-org/docker-archlinux-aur

# probably is ab
ARG AUR_USER

# can be paru or yay
ARG HELPER

# install helper and add a user for it
ADD add-aur.sh /root
RUN bash /root/add-aur.sh "${AUR_USER}" "${HELPER}"

# now to install from the AUR, you might do something like this in your dockerfile:
#RUN sudo -u ab -D~ bash -c 'paru -Syu --needed --noprogressbar --noconfirm PACKAGE; yes|paru -Scc'
# or for yay
#RUN sudo -u ab -D~ bash -c 'yay -Syu --removemake --needed --noprogressbar --noconfirm PACKAGE'
