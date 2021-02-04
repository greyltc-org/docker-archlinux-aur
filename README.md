archlinux-aur
====================
The Official Arch Linux Docker image after installing an AUR helper. (containers for both yay and paru)

- Uses the official Arch base-devel image, `FROM archlinux:base-devel` ( see https://hub.docker.com/_/archlinux )
- Builds every week on Sunday, two hours after the official archlinux:base-devel package is built
- Uses the same tag syntax as that container
- Report issues here: https://github.com/greyltc/docker-archlinux-aur/issues
- Automated builds done and published on Docker Hub 
  - https://hub.docker.com/repository/docker/greyltc/archlinux-aur
- Github actions builds also done and published on the Github Container Registry
  - https://github.com/users/greyltc/packages/container/package/archlinux-aur
- There are a few tags here
  - `latest`, `20210203.0.54`, `yay`, `yay-20210203.0.54` builds with yay helper
  - `paru`, `paru-20210203.0.54` builds with paru helper
- You can use one yourself by putting something like this at the top of your Dockerfile
  - `FROM greyltc/archlinux-aur`
  - `FROM greyltc/archlinux-aur:paru`
  - `FROM greyltc/archlinux-aur:yay`
  - `FROM greyltc/archlinux-aur:paru-20210203.0.54`
  - `FROM greyltc/archlinux-aur:yay-20210203.0.54`
  - `FROM ghcr.io/greyltc/archlinux-aur`
  - `FROM ghcr.io/greyltc/archlinux-aur:paru`
  - `FROM ghcr.io/greyltc/archlinux-aur:yay`
  - `FROM ghcr.io/greyltc/archlinux-aur:paru-20210203.0.54`
  - `FROM ghcr.io/greyltc/archlinux-aur:yay-20210203.0.54`

Containers based on this one can do something like this to install `PACKAGE` from the AUR:
```bash
sudo -u ab -D~ bash -c 'yay -Syu --removemake --needed --noprogressbar --noconfirm PACKAGE'
```

So then in your Dockerfile, that would look something like:
```dockerfile
RUN sudo -u ab -D~ bash -c 'yay -Syu --removemake --needed --noprogressbar --noconfirm PACKAGE'
```

Do this to poke around inside the container if you'd like:
```
docker run --name checkitout --pull=always --interactive --tty greyltc/archlinux-aur bash
```
