[![](https://images.microbadger.com/badges/image/greyltc/archlinux-aur.svg)](http://microbadger.com/images/greyltc/archlinux-aur) [![](https://images.microbadger.com/badges/version/greyltc/archlinux-aur.svg)](https://hub.docker.com/r/greyltc/archlinux-aur/)

docker-archlinux-aur
====================
The Official Arch Linux Docker image after installing an AUR helper. (containers for both yay and paru)

- Uses the official Arch base-devel image: `FROM archlinux:base-devel` ( https://hub.docker.com/_/archlinux )
- Builds every week on Sunday, two hours after the official archlinux:base-devel package is built
- Uses the same tag syntax as that container
- Report issues here: https://github.com/greyltc/docker-archlinux-aur/issues
- Published on Docker Hub 
  - https://hub.docker.com/repository/docker/greyltc/archlinux-aur
  - https://hub.docker.com/repository/docker/greyltc/archlinux-yay
  - https://hub.docker.com/repository/docker/greyltc/archlinux-paru
- Also published on the Github Container Registry
  - https://github.com/users/greyltc/packages/container/package/archlinux-aur
  - https://github.com/users/greyltc/packages/container/package/archlinux-yay
  - https://github.com/users/greyltc/packages/container/package/archlinux-paru
- You can use one yourself by putting something like this at the top of your Dockerfile
  - `FROM greyltc/archlinux-paru`, the latest version with paru helper
  - `FROM greyltc/archlinux-yay`, the latest version with yay helper
  - `FROM greyltc/archlinux-aur`, the latest version with yay helper
  - `FROM greyltc/archlinux-aur:20210107.0.13`, a specific version
  - `FROM ghcr.io/greyltc/archlinux-aur`, the latest version from the Github Container Registry
  - `FROM ghcr.io/greyltc/archlinux-aur:20210107.0.13`, a specific version from the Github Container Registry

Containers based on this one can use the following to install `PACKAGE` from the AUR:
```bash
sudo -u ab -D~ bash -c 'yay -Syu --removemake --needed --noprogressbar --noconfirm PACKAGE'
```

So then in your Dockerfile, that would look like:
```dockerfile
RUN sudo -u ab -D~ bash -c 'yay -Syu --removemake --needed --noprogressbar --noconfirm PACKAGE'
```

Do this to poke around inside the container if you'd like:
```
docker run --name checkitout --pull=always --interactive --tty greyltc/archlinux-aur bash
```
