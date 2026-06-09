# home-manager-only

Standalone home-manager configuration for the `kt` user. No NixOS or root access required.

## Apply from a local checkout

```bash
home-manager switch --flake .#kt
```

Run from the `home-manager-only/` directory, or pass the path explicitly:

```bash
home-manager switch --flake /path/to/k-nixos/home-manager-only#kt
```

## Apply directly from GitHub

No checkout needed — pull and apply in one command:

```bash
home-manager switch --flake "github:KeeTraxx/k-nixos?dir=home-manager-only#kt"
```
