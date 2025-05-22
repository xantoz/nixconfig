{ pkgs, lib, config, ... }:
let
  languageServers = with pkgs; [
    elixir_ls
    gopls
    clang-tools
    lldb
    gdb
    cmake-language-server
    cmake
    nil
    # nixd
    nodePackages.bash-language-server
    python3Packages.python-lsp-server
  ];
  extraPackages = ((import ../emacs-parse/parse.nix) { inherit pkgs; inherit lib; }).usePackagePkgs {
    config = ./config/emacs/init.el;
    extraPackages = [ "vterm" ];
  };
  myEmacs = pkgs.emacs.pkgs.withPackages extraPackages;
  emacsWithLanguageServers =
    pkgs.runCommand "emacs-with-language-servers" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${myEmacs}/bin/emacs $out/bin/emacs --prefix PATH : ${lib.makeBinPath languageServers}
    '';
in {
  home.packages = with pkgs; [
    emacsWithLanguageServers
    cscope                      # FIXME?: This also pulls in emacs, and not neccessarily the one we pass for emacs package above. This can cause double builds of emacs.
    (writeShellScriptBin "ec" ''
      exec emacsclient "$@"
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
