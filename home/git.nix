{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "xantoz";
      email = "bountyjedi@gmail.com";
    };
  };
}
