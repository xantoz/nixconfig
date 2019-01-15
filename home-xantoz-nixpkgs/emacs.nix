{ pkgs, ... }:

{
  programs.emacs.enable = true;
  programs.emacs.extraPackages = epkgs: with epkgs; [
    magit
    ag
    buffer-move
    use-package
    find-file-in-project
  ];

  home.file = {
    ".config/emacs".source = ./config/emacs;
    ".emacs".source = pkgs.writeText "dotemacs" ''
      (load "~/.config/emacs/init.el")
    '';
  };
}
