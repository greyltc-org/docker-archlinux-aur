docker-archlinux-aur
====================
Minimal Arch Linux docker image with base-devel group and yaourt installed  

The default user here is not root, rather it is a user called 'docker'. Commands requiring root permissions should be prefixed with 'sudo'.

Get the prebuilt image from here: https://registry.hub.docker.com/u/l3iggs/archlinux-aur/  
or build it locally yourself from the source repo:  
```
git clone https://github.com/l3iggs/docker-archlinux-aur.git
cd docker-archlinux-aur
docker build -t docker-archlinux-aur .
```
