{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "k-nixos-update" ''
      if [ "$(id -u)" -ne 0 ]; then
        exec sudo "$0" "$@"
      fi
      export PATH="/run/current-system/sw/bin:$PATH"
      exec nixos-rebuild switch --flake "github:KeeTraxx/k-nixos#$(hostname)" --refresh --no-write-lock-file
    '')
  ];
}
