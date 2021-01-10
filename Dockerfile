# Arch Linux base docker container with yay for AUR access
FROM archlinux:base-devel
LABEL maintainer="Grey Christoforo <grey@christoforo.net>"
LABEL source="https://github.com/greyltc/docker-archlinux-aur"

# install yay and add a user for it: aurbuilder
ENV AUR_USER=aurbuilder
ADD add-aur.sh /root
RUN bash /root/add-aur.sh ${AUR_USER}

# now to install from the AUR, you can do this:
#RUN sudo -u aurbuilder -D~ bash -c 'yay -Syu --removemake --needed --noprogressbar --noconfirm PACKAGE'
