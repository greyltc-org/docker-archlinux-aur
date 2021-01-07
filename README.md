[![](https://images.microbadger.com/badges/image/greyltc/archlinux-aur.svg)](http://microbadger.com/images/greyltc/archlinux-aur) [![](https://images.microbadger.com/badges/version/greyltc/archlinux-aur.svg)](https://hub.docker.com/r/greyltc/archlinux-aur/)

docker-archlinux-aur
====================
The Official Arch Linux Docker image after installing yay. yay is an [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) written in go.

- Uses the official Arch base-devel image: `FROM archlinux:base-devel` ( https://hub.docker.com/_/archlinux )
- Builds every week on Sunday, two hours after the official archlinux:base-devel package is built
- Uses the same tag syntax as that container
- Report issues here: https://github.com/greyltc/docker-archlinux-aur/issues
- Published on Docker Hub 
  - https://hub.docker.com/repository/docker/greyltc/archlinux-aur
- Also published on the Github Container Registry
  - https://github.com/users/greyltc/packages/container/package/archlinux-aur
- You can use it yourself by putting something like this at the top of your Dockerfile
  - `FROM greyltc/archlinux-aur`, the latest version
  - `FROM greyltc/archlinux-aur:20210107.0.13`, a specific version
  - `FROM ghcr.io/greyltc/archlinux-aur`, the latest version from the Github Container Registry
  - `FROM ghcr.io/greyltc/archlinux-aur:20210107.0.13`, a specific version from the Github Container Registry

Containers based on this one can use the following to install `PACKAGE` from the AUR:
```bash
su aurbuilder -c 'yay -S --noprogressbar --removemake --needed --noconfirm PACKAGE'
```

So in your Dockerfile, that would look like:
```dockerfile
RUN su aurbuilder -c 'yay -S --noprogressbar --removemake --needed --noconfirm PACKAGE'
```

Poke around inside the container:
```
docker run --pull=always -i -t greyltc/archlinux-aur bash
```
