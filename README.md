archlinux-aur
====================
The Official Arch Linux Docker image after installing an AUR helper. (containers for both yay and paru)

- Uses the official Arch base-devel image, `FROM archlinux:base-devel` ( see https://hub.docker.com/_/archlinux )
- Builds every week on Sunday, two hours after the official archlinux:base-devel package is built
- Uses the same tag syntax as that container
- Report issues here: https://github.com/greyltc/docker-archlinux-aur/issues
- Automated builds are done via GitHub Actions which publish finished containers to two places:
  - Docker Hub
    - https://hub.docker.com/repository/docker/greyltc/archlinux-aur
  - GitHub Container Registry
    - https://github.com/greyltc-org/docker-archlinux-aur/pkgs/container/archlinux-aur
- There are a few tags here
  - `latest`, `20210203.0.54`, `yay`, `yay-20210203.0.54` builds with yay helper
  - `paru`, `paru-20210203.0.54` builds with paru helper
- You can use one yourself by putting something like this at the top of your Dockerfile  
  - **From Docker Hub:**
    - `FROM greyltc/archlinux-aur`
    - `FROM greyltc/archlinux-aur:paru`
    - `FROM greyltc/archlinux-aur:yay`
    - `FROM greyltc/archlinux-aur:paru-20210203.0.54`
    - `FROM greyltc/archlinux-aur:yay-20210203.0.54`  
  - **From GitHub Package Registry:**
    - `FROM ghcr.io/greyltc-org/archlinux-aur`
    - `FROM ghcr.io/greyltc-org/archlinux-aur:paru`
    - `FROM ghcr.io/greyltc-org/archlinux-aur:yay`
    - `FROM ghcr.io/greyltc-org/archlinux-aur:paru-20210203.0.54`
    - `FROM ghcr.io/greyltc-org/archlinux-aur:yay-20210203.0.54`

To install stuff in a container based on this project you can put something like the following in your Dockerfile:
```dockerfile
RUN aur-install aur-package1 aur-package2 non-aur-package3
```

Do this to poke around inside the container if you'd like:
```
docker run --name checkitout --pull=always --interactive --tty ghcr.io/greyltc-org/archlinux-aur bash
```
