{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cscope
    (writeShellScriptBin "ec" ''
      exec emacsclient "$@"
    '')
  ];

  programs.emacs.package = pkgs.emacs26;
  programs.emacs.enable = true;
  programs.emacs.extraPackages = epkgs: with epkgs; [
    magit
    ag
    buffer-move
    use-package
    find-file-in-project
    # lua-mode
  ];

  services.emacs.enable = true;

  home.file = {
    ".config/emacs".source = ./config/emacs;
    ".emacs".source = pkgs.writeText "dotemacs" ''
      (load "~/.config/emacs/init.el")
    '';
  };
}
