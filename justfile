default: nixos-update-local

nix-validate:
    nix flake check --no-build

nixos-update-local:
    #!/usr/bin/env bash
    if command -v nixos-version &>/dev/null; then
        nh os switch .# -c "$(hostname)"
    else
        nh home switch ./home-manager-only -c $(whoami) --impure
    fi
