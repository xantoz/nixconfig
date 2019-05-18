{ pkgs, lib, config, ... }:

{
  services.emacs.enable = true;
  programs.emacs.enable = true;
  programs.emacs.package = pkgs.emacsVcs27;
  programs.emacs.extraPackages =
    let
      inherit (pkgs.callPackage ./config/emacs/scripts/nix-emacs-with-use-package-pkgs/emacs-with-use-package-pkgs.nix { emacs = pkgs.emacsVcs27; }) usePackagePkgs;
    in usePackagePkgs { config = ./config/emacs/init.el; };

  home.packages = with pkgs; [
    cscope
    (writeShellScriptBin "ec" ''
      exec emacsclient "$@"
    '')
    (pkgs.runCommand "dumped-emacs" {} ''
      mkdir -p $out/bin
      mkdir -p $out/lib
      HOME=$out ${config.programs.emacs.finalPackage}/bin/emacs -Q -nw --batch -l ${./config/emacs}/init.el --execute '(progn (global-font-lock-mode t) (write-region (format "(setq load-path (quote %S))" load-path) nil "'$out'/lib/emacs-loadpath.el") (dump-emacs-portable "'$out'/lib/emacs.bdump") (kill-emacs))'
      cat > $out/bin/qemacs <<EOF
      #!/bin/sh
      exec ${config.programs.emacs.finalPackage}/bin/emacs -Q --dump-file $out/lib/emacs.bdump --load $out/lib/emacs-loadpath.el "\$@"
      EOF
      chmod +x $out/bin/qemacs
    '')
  ];

  home.file = {
    ".config/emacs".source = ./config/emacs;
    ".emacs".source = pkgs.writeText "dotemacs" ''
      (load "~/.config/emacs/init.el")
    '';
  };
}
