{ pkgs, lib, config, ... }:

{
  services.emacs.enable = true;
  programs.emacs.enable = true;
  programs.emacs.package = pkgs.emacs28;
  programs.emacs.extraPackages =
    let
      inherit (pkgs.callPackage ./config/emacs/scripts/nix-emacs-with-use-package-pkgs/emacs-with-use-package-pkgs.nix {
        emacs = pkgs.emacs28;
      }) usePackagePkgs;
    in usePackagePkgs {
      config = ./config/emacs/init.el;
      extraPackages = [ "vterm" ];
    };

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
    # TODO: how to deal with ~/.emacs-custom ?
    ".config/emacs.d".source = ./config/emacs;
    # ".config/emacs".source = ./config/emacs;
    ".emacs".source = pkgs.writeText "dotemacs"
      ''
        (load "~/.config/emacs.d/init.el")

        ;; fix image-dired on NixOS
        (setq image-dired-cmd-create-thumbnail-program   "${pkgs.imagemagick}/bin/convert"
              image-dired-cmd-create-temp-image-program  "${pkgs.imagemagick}/bin/convert"
              image-dired-cmd-rotate-thumbnail-program   "${pkgs.imagemagick}/bin/mogrify"
              image-dired-cmd-rotate-original-program    "${pkgs.libjpeg_turbo}/bin/jpegtran"
              image-dired-cmd-pngnq-program              "${pkgs.pngnq}/bin/pngnq"
              image-dired-cmd-pngcrush-program           "${pkgs.pngcrush}/bin/pngcrush"
              image-dired-cmd-optipng-program            "${pkgs.optipng}/bin/optipng"
              image-dired-cmd-write-exif-data-program    "${pkgs.exiftool}/bin/exiftool"
              image-dired-cmd-read-exif-data-program     "${pkgs.exiftool}/bin/exiftool")
     '';
  };
}
