# k-nixos

Nix configuration to bootstrap a NixOS machine.

## Manual

1. Boot VM with nixos-minimal iso from https://nixos.org/download/
2. Wait for terminal
3. `sudo sh -c 'bash <(curl -s https://raw.githubusercontent.com/KeeTraxx/k-nixos/main/install.sh)'`

## Practice installation in a VM

1. Download minimal ISO https://nixos.org/download/
2. (optional) update `docker-compose.yml` to mount the iso
3. Boot up a VM using `docker-compose up -d`
3. Goto `http://localhost:8006`