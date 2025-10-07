# k-nixos

Nix configuration to bootstrap a NixOS machine.

## Manual

1. Boot VM with nixos-minimal iso from https://nixos.org/download/
2. Wait for terminal
3. Check out k-nixos `git clone https://github.com/KeeTraxx/k-nixos.git`
4. `cd k-nixos`
5. `sudo ./install.sh`
6. `sudo nixos-install --flake .#<HOSTNAME> --impure`