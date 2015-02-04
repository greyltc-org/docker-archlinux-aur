docker-archlinux-aur
====================
Minimal Arch Linux docker image with trustable, traceable & inspectable origin. Base-devel group, yaourt and packer installed for easy AUR access  

The default user here is not root, rather it is a user called 'docker'. Commands requiring root permissions should be prefixed with 'sudo'.

## Usage
Get the trustable, AUTOMATED BUILD prebuilt image from [https://registry.hub.docker.com/u/l3iggs/archlinux-aur/](https://registry.hub.docker.com/u/l3iggs/archlinux-aur/):  
```bash
docker pull l3iggs/archlinux-aur
```  
or build it locally yourself from the source repository:  

1. **Clone the Dockerfile repo**  
`git clone https://github.com/l3iggs/docker-archlinux-aur.git`  
1. **Build your docker image**  
`cd docker-archlinux-aur`  
`docker build -t archlinux-aur .`  
1. **Profit.**
