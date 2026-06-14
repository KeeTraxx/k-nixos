{ ... }:

{
  programs.mise = {
    enable = true;
    globalConfig = {
      tools = {
        node = [
          "lts"
        ];
      };
      settings = {
        node_compile = false;
      };
    };
  };
}
