{ ... }:

{
  programs.mise = {
    enable = true;
    globalConfig = {
      tools = {
        node = [
          "24"
        ];
      };
      settings = {
        all_compile = false;
      };
    };
  };
}
