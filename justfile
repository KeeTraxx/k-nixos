default: nixos-update-local

nix-validate:
    nix flake check --no-build

nixos-update-local:
    #!/usr/bin/env bash
    if command -v nixos-version &>/dev/null; then
        nh os switch .#$(hostname)
    else
        nh home switch ./home-manager-only -c $(whoami) --impure
    fi
    just pin-gcroots

nix-flake-update:
    nix flake update
    nix flake update --flake ./home-manager-only

# Pin a GC root for ~/.local/state/nix/profiles/profile (holds home.packages,
# e.g. the home-manager/nh binaries). Home Manager's activate script only
# self-protects the "home-manager" generation (current-home/new-home); the
# package profile has no equivalent root and can get swept by a plain
# nix-collect-garbage. Re-run after every switch since the target changes.
pin-gcroots:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p ~/.local/state/nix/gcroots-mine
    nix-store --add-root ~/.local/state/nix/gcroots-mine/profile --indirect \
        -r "$(readlink -f ~/.local/state/nix/profiles/profile)"

nix-janitor:
    just pin-gcroots
    home-manager expire-generations "-30 days"
    nix-collect-garbage   # as yourself, no sudo

nix-tree:
    #!/usr/bin/env bash
    if command -v nixos-version &>/dev/null; then
        nix-tree $(nix eval --raw .#$(hostname).activationPackage)
    else
        nix-tree $(nix eval --raw .#homeConfigurations.$(whoami).activationPackage) --impure
    fi
