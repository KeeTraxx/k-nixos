{ pkgs, ... }: {
  programs.niri.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  xdg.portal.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Required by DMS
  services.power-profiles-daemon.enable = true;
  services.accounts-daemon.enable = true;
  services.geoclue2.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  systemd.user.services.dms = {
    description = "Dank Material Shell";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    restartIfChanged = false;
    serviceConfig = {
      ExecStart = "${pkgs.unstable.dms-shell}/bin/dms run --session";
      Restart = "on-failure";
      Environment = "PATH=${pkgs.unstable.quickshell}/bin:${pkgs.unstable.dms-shell}/bin:/run/current-system/sw/bin:/run/current-system/sw/sbin";
    };
  };

  environment.systemPackages = with pkgs; [
    unstable.dms-shell
    unstable.quickshell
    foot # terminal
    swaylock # screen lock
    swayidle # idle management
    xwayland-satellite # X11 app support
    wl-clipboard
    grim # screenshot
    slurp # screen area selection
  ];
}
