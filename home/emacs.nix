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
      packages =
        let
          inherit (pkgs.callPackage ./config/emacs/scripts/nix-emacs-with-use-package-pkgs/emacs-with-use-package-pkgs.nix {}) parsePackages;
        in (parsePackages ./config/emacs/init.el);
    in (epkgs: map (name: epkgs.${name}) (packages ++ [ "use-package" ]));

  home.file = {
    ".config/emacs".source = ./config/emacs;
    ".emacs".source = pkgs.writeText "dotemacs" ''
      (load "~/.config/emacs/init.el")
    '';
  };
}
