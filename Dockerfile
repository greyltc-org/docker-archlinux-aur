# Arch Linux base docker container with pacaur for AUR access
FROM greyltc/archlinux
MAINTAINER Grey Christoforo <grey@christoforo.net>

# setup aur access for a new user "docker"
ADD add-aur.sh /usr/sbin/add-aur
RUN add-aur docker

# switch to that user
USER docker
WORKDIR /home/docker

