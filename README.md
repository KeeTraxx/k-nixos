# k-nixos

Personal NixOS configurations. Hosts are installed remotely from a dev machine using [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) — the target only needs to boot a NixOS live ISO and be reachable over SSH.

## Repository structure

```
hosts/
  <hostname>/
    default.nix             # Host config: networking, bootloader, users, …
    disk.nix                # Disko disk layout (GPT + LUKS + ext4)
    hardware-configuration.nix  # Generated during install, committed afterwards
modules/
  common.nix                # Shared config applied to every host
users/
  <username>/
    default.nix             # System-level user declaration + home-manager hook
    home.nix                # Home-manager config (packages, git, shell, …)
scripts/
  add-host.sh               # Scaffold a new host config
  install.sh                # Install NixOS on a remote machine
flake.nix                   # Flake: hosts auto-discovered from hosts/
```

## Prerequisites

- Nix with flakes enabled on the dev machine
- Target machine booted from a [NixOS minimal ISO](https://nixos.org/download/), reachable via SSH as `root`

## Installation

### 1. Scaffold the host (optional)

If you want to review or customise the config before installing, scaffold it first:

```bash
scripts/add-host.sh <hostname> <disk>
```

| Argument | Description |
|---|---|
| `hostname` | Name for the new machine (e.g. `myhost`) |
| `disk` | Target block device (e.g. `/dev/nvme0n1`) |

This creates `hosts/<hostname>/` with a `default.nix`, a disko `disk.nix` (GPT, 512 MB EFI, rest LUKS-encrypted ext4), and a stub `hardware-configuration.nix`. Edit `default.nix` to add users, desktop environments, or other host-specific options before continuing.

### 2. Install

```bash
scripts/install.sh [--port PORT] <hostname> [disk] <target-ip>
```

| Argument | Required | Description |
|---|---|---|
| `--port PORT` | No | SSH port on the target (default: 22) |
| `hostname` | Yes | Must match a config in `hosts/` or will be scaffolded automatically |
| `disk` | No | Block device to install on. If omitted, the first disk found on the target is used |
| `target-ip` | Yes | IP address of the target machine |

**What happens:**

1. If `hosts/<hostname>/` does not exist, `add-host.sh` is called automatically with the detected or provided disk.
2. If `flake.lock` is missing, `nix flake update` is run.
3. You are prompted for a LUKS passphrase (entered once, confirmed, never stored).
4. [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) takes over:
   - kexec's the target into a NixOS installer environment
   - Runs [disko](https://github.com/nix-community/disko) to partition the disk and set up LUKS
   - Builds and installs the NixOS system closure from the local flake
   - Generates `hosts/<hostname>/hardware-configuration.nix` on the target and writes it back locally
5. The target reboots into the new system.

The repo is **never cloned on the target machine**. nixos-anywhere builds the system closure locally and copies it over SSH.

**Examples:**

```bash
# Simplest: auto-detect disk, default SSH port
scripts/install.sh myhost 192.168.1.42

# Explicit disk
scripts/install.sh myhost /dev/nvme0n1 192.168.1.42

# Non-standard SSH port
scripts/install.sh --port 2222 myhost 192.168.1.42

# All options
scripts/install.sh --port 2222 myhost /dev/nvme0n1 192.168.1.42
```

### 3. Commit the generated hardware config

After install, `hosts/<hostname>/hardware-configuration.nix` has been populated with the real hardware config (CPU microcode, kernel modules, etc.). Commit it so future reinstalls can skip the live ISO:

```bash
git add hosts/<hostname>
git commit -m "Add <hostname>"
git push
```

### Future reinstalls

Once the hardware config is committed, reinstalling requires no live ISO preparation on the target side — just boot any Linux with SSH and run:

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake github:keetraxx/k-nixos#<hostname> \
  [--ssh-port PORT] \
  root@<ip>
```

## Applying home-manager (standalone, no NixOS)

The `home-manager-only/` directory contains a standalone flake that works on any system with Nix installed.

```bash
NIXPKGS_ALLOW_INSECURE=1 NIX_CONFIG="experimental-features = nix-command flakes" nix run "github:nix-community/home-manager/release-26.05" -- switch --impure --flake "github:KeeTraxx/k-nixos?dir=home-manager-only#kt"
```

> This uses `nix run` to invoke home-manager directly, so nothing needs to be installed beforehand. See `home-manager-only/README.md` for more options (local checkout, with nixGL, etc.).

If you have nix-helper installed, you can use it to run home-manager without the `NIX_CONFIG` environment variable:

```bash
NIXPKGS_ALLOW_INSECURE=1 NIX_CONFIG="experimental-features = nix-command flakes" nh home switch --impure github:KeeTraxx/k-nixos?dir=home-manager-only -c kt
```

## Adding a user

1. Create `users/<username>/default.nix` and `users/<username>/home.nix`, following `users/kt/` as a template.
2. Import the user in the relevant host's `default.nix`:

```nix
imports = [
  ...
  ../../users/<username>/default.nix
];
```

## Updating flake.lock

`flake.lock` pins every input (nixpkgs, home-manager, disko) to an exact commit. Update it to pull in the latest packages:

```bash
nix flake update
git add flake.lock
git commit -m "Update flake.lock"
git push
```

Run `scripts/update.sh` afterwards to deploy the new packages to your hosts.

To update a single input without touching the rest:

```bash
nix flake update nixpkgs
```

## Updating a host

```bash
scripts/update.sh [--port PORT] <hostname> <target-ip>
```

Builds the new system closure locally and activates it on the remote host over SSH. The target does not need Nix installed.

```bash
scripts/update.sh myhost 192.168.1.42
scripts/update.sh --port 2222 myhost 192.168.1.42
```
