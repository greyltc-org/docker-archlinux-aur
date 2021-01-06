# Arch Linux base docker container with yay for AUR access
FROM archlinux:base-devel
MAINTAINER Greyson Christoforo <grey@christoforo.net>

# setup aur access for a new user "aurbuilder"
ADD add-aur.sh /usr/sbin/add-aur
RUN add-aur aurbuilder

# now to install from the AUR, you can do this:
# su aurbuilder -c "yay -S --noprogressbar --needed --noconfirm $PACKAGENAME"
