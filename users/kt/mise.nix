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
        all_compile = false;
      };
    };
  };
}
