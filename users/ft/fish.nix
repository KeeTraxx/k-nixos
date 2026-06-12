{ pkgs, lib, ... }:
{
  # Tide config goes in conf.d so fish_variables stays writable by other programs
  # (e.g. `tide configure` and fish itself).
  # To populate tide.fish: run `set | grep ^tide | awk '{print "set -U "$1" "$2}'`
  xdg.configFile."fish/conf.d/tide.fish" = lib.mkIf (builtins.pathExists ./tide.fish) {
    source = ./tide.fish;
  };

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
