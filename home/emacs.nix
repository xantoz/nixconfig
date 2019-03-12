{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cscope
    (writeShellScriptBin "ec" ''
      exec emacsclient "$@"
    '')
  ];

  services.emacs.enable = true;
  programs.emacs.enable = true;
  programs.emacs.package = pkgs.emacs26;
  programs.emacs.extraPackages =
    let
      inherit (pkgs.callPackage ./config/emacs/scripts/nix-emacs-with-use-package-pkgs/emacs-with-use-package-pkgs.nix {}) emacsUsePackagePkgsClosure;
    in emacsUsePackagePkgsClosure { config = ./config/emacs/init.el; };

  home.file = {
    ".config/emacs".source = ./config/emacs;
    ".emacs".source = pkgs.writeText "dotemacs" ''
      (load "~/.config/emacs/init.el")
    '';
  };
}
