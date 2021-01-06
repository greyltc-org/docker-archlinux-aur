[![](https://images.microbadger.com/badges/image/greyltc/archlinux-aur.svg)](http://microbadger.com/images/greyltc/archlinux-aur) [![](https://images.microbadger.com/badges/version/greyltc/archlinux-aur.svg)](https://hub.docker.com/r/greyltc/archlinux-aur/)

docker-archlinux-aur
====================
Official Arch Linux Docker image with yay:

Containers based on this one can use the following to install `PACKAGE` from the AUR:
```bash
su aurbuilder -c 'yay -S --noprogressbar --needed --noconfirm PACKAGE'
```

So in your Dockerfile, that would look like:
```dockerfile
RUN su aurbuilder -c 'yay -S --noprogressbar --needed --noconfirm PACKAGE'
```
