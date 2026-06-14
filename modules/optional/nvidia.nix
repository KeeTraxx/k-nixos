{ pkgs, ... }: {
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = pkgs.unstable.linuxPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs.unstable; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia-container-toolkit.enable = true;
}
