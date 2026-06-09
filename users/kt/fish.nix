{ pkgs, lib, ... }:
{
  xdg.configFile."fish/fish_variables".text = lib.concatStrings [
    (builtins.readFile ./tide_variables)
  ];

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      {
        name = "fish-cd-gitroot";
        src = pkgs.fetchFromGitHub {
          owner = "mollifier";
          repo = "fish-cd-gitroot";
          rev = "9b5c3732655ee99aefae04739242d6a1bab47be1";
          sha256 = "0nsk1v143ksph5m680hw11hpqizpzpkl5dfmwj5wi0hbklipbkm1";
        };
      }
    ];
  };
}
