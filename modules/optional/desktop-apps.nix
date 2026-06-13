{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    brave
    firefox
    chromium
    krita
  ];

  programs.firefox = {
    enable = true;
  };

}
