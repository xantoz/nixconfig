{ pkgs, ... }:

{
  programs.emacs.enable = true;
  programs.emacs.extraPackages = epkgs: with epkgs; [
    magit
    nix-mode
    ag
    buffer-move
    use-package
  ];
}
