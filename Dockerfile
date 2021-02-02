# Arch Linux base docker container with yay for AUR access
FROM archlinux:base-devel
LABEL maintainer="Greyson Christoforo <grey@christoforo.net>"
LABEL source="https://github.com/greyltc/docker-archlinux-aur"

# install yay and add a user for it: aurbuilder
ENV AUR_USER=aurbuilder
ENV HELPER=yay
ADD add-aur.sh /root
RUN bash /root/add-aur.sh "${AUR_USER}" "${HELPER}"

# now to install from the AUR, you might do something like this in your dockerfile:
#RUN sudo -u aurbuilder -D~ bash -c '${HELPER} -Syu --removemake --needed --noprogressbar --noconfirm PACKAGE'
