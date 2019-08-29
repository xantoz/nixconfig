{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Anton Kindestam";
    userEmail = "antonki@kth.se";
  };
}
