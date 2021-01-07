# Arch Linux base docker container with yay for AUR access
FROM archlinux:base-devel
MAINTAINER Greyson Christoforo <grey@christoforo.net>

# install yay and add a user for it: aurbuilder
ENV AUR_USER=aurbuilder
ADD add-aur.sh /root/
RUN bash /root/add-aur.sh ${AUR_USER}

# now to install from the AUR, you can do this:
# su ${AUR_USER} -c "yay -S --noprogressbar --needed --noconfirm package1 package2"
