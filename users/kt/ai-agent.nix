{ config, ... }:
let
  agentDir = "${config.xdg.configHome}/ai-agent";
in {
  # Shared skills/commands live in ~/.config/ai-agent (deployed by config-files.nix).
  # Each agent's expected path is symlinked at it so one definition feeds all of them.
  home.file = {
    ".claude/skills".source = config.lib.file.mkOutOfStoreSymlink "${agentDir}/skills";
    ".claude/commands".source = config.lib.file.mkOutOfStoreSymlink "${agentDir}/commands";
  };
}
