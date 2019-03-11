{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cscope
    (writeShellScriptBin "ec" ''
      exec emacsclient "$@"
    '')
    (let
      inherit (pkgs.callPackage ./config/emacs/scripts/nix-emacs-with-use-package-pkgs/emacs-with-use-package-pkgs.nix {}) emacsWithUsePackagePkgs;
    in (emacsWithUsePackagePkgs {
      config = ./config/emacs/init.el;
    }))
  ];

  services.emacs.enable = false;
  programs.emacs.enable = false;

  home.file = {
    ".config/emacs".source = ./config/emacs;
    ".emacs".source = pkgs.writeText "dotemacs" ''
      (load "~/.config/emacs/init.el")
    '';
  };
}
