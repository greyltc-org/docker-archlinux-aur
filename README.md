[![](https://images.microbadger.com/badges/image/greyltc/archlinux-aur.svg)](http://microbadger.com/images/greyltc/archlinux-aur) [![](https://images.microbadger.com/badges/version/greyltc/archlinux-aur.svg)](https://hub.docker.com/r/greyltc/archlinux-aur/)

docker-archlinux-aur
====================
This is exactly the same as https://github.com/greyltc/docker-archlinux with the following exception:

Containers based on this one can use the following to install `PACKAGE` from the AUR:
```bash
su docker -c 'pacaur -S --noprogressbar --noedit --noconfirm PACKAGE'
```

So in your Dockerfile, that would look like:
```dockerfile
RUN su docker -c 'pacaur -S --noprogressbar --noedit --noconfirm PACKAGE'
```
