{ pkgs, ...}:

{
  allowUnfree = true;

  nix.maxJobs = 4;

  packageOverrides = pkgs_: {

    my_mpv = pkgs.writeShellScriptBin "mpv" ''
      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.lib.makeLibraryPath [
        pkgs.mesa_drivers
        pkgs.zlib
        pkgs.libdrm
        pkgs.xorg.libX11
        pkgs.xorg.libxcb
        pkgs.xorg.libxshmfence
        pkgs.wayland
        pkgs.gcc.cc
        pkgs.expat
        pkgs.llvm_7
        pkgs.vulkan-loader
      ]}:'$LD_LIBRARY_PATH
      export LIBVA_DRIVERS_PATH='${pkgs.vaapiIntel}/lib/dri'
      exec ${pkgs.mpv}/bin/mpv "$@"
    '';

    my_alacritty = pkgs.writeShellScriptBin "alacritty" ''
      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.lib.makeLibraryPath [
        pkgs.mesa_drivers
        pkgs.zlib
        pkgs.libdrm
        pkgs.xorg.libX11
        pkgs.xorg.libxcb
        pkgs.xorg.libxshmfence
        pkgs.wayland
        pkgs.gcc.cc
        pkgs.expat
        pkgs.llvm_7
        pkgs.vulkan-loader
      ]}:'$LD_LIBRARY_PATH
      export LIBVA_DRIVERS_PATH='${pkgs.vaapiIntel}/lib/dri'
      exec ${pkgs.alacritty}/bin/alacritty "$@" -e /bin/sh -c "unset LIBGL_DRIVERS_PATH; unset LD_LIBRARY_PATH; unset LIBVA_DRIVERS_PATH; exec $SHELL"
    '';

    my_mpc-qt = pkgs.writeShellScriptBin "mpc-qt" ''
      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.mesa_drivers}/lib':$LD_LIBRARY_PATH
      exec ${pkgs.mpc-qt}/bin/mpc-qt "$@"
    '';

    my_webmacs = pkgs.writeShellScriptBin "webmacs" ''
      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.mesa_drivers}/lib':$LD_LIBRARY_PATH
      exec ${pkgs.webmacs}/bin/webmacs "$@"
    '';

    my_vainfo = pkgs.writeShellScriptBin "vainfo" ''
      export LIBVA_DRIVERS_PATH='${pkgs.vaapiIntel}/lib/dri'
      exec ${pkgs.libva-utils}/bin/vainfo "$@"
    '';

    my_pulseview = pkgs.writeScriptBin "pulseview" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p python3

      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.mesa_drivers}/lib'""''${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH
      exec ${pkgs.pulseview}/bin/pulseview "$@"
    '';

    nixGLIntel = pkgs.writeShellScriptBin "nixGLIntel" ''
      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.mesa_drivers}/lib':$LD_LIBRARY_PATH
      exec "$@"
    '';

    nixIntel = pkgs.writeShellScriptBin "nixIntel" ''
      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.lib.makeLibraryPath [
        pkgs.mesa_drivers
        pkgs.zlib
        pkgs.libdrm
        pkgs.xorg.libX11
        pkgs.xorg.libxcb
        pkgs.xorg.libxshmfence
        pkgs.wayland
        pkgs.gcc.cc
        pkgs.expat
        pkgs.llvm_7
      ]}':$LD_LIBRARY_PATH
      export LIBVA_DRIVERS_PATH='${pkgs.vaapiIntel}/lib/dri'
      exec "$@"
    '';

    all = pkgs.buildEnv {
      name = "all";

      paths = [
        pkgs.my_mpc-qt
        pkgs.my_mpv
        pkgs.my_webmacs

        pkgs.emacs26

        pkgs.my_pulseview
        pkgs.my_alacritty

        pkgs.nixGLIntel
        pkgs.nixIntel

        pkgs.xterm
        pkgs.youtube-dl
        pkgs.hugo

        pkgs.pamixer
        pkgs.ponymix
        # pkgs.pulsemixer
        # pkgs.ncpamixer

        # pkgs.imv

        # pkgs.firefox-wayland
        # pkgs.firefox

        # fonts
        pkgs.font-awesome
        pkgs.font-awesome-ttf

        pkgs.noto-fonts-emoji
        pkgs.emacs-all-the-icons-fonts
        pkgs.source-code-pro
        pkgs.source-sans-pro
        pkgs.source-serif-pro
        pkgs.source-han-code-jp
        pkgs.source-han-sans-japanese
        pkgs.source-han-serif-japanese
        pkgs.source-han-sans-korean
        pkgs.source-han-serif-korean
        pkgs.source-han-sans-simplified-chinese
        pkgs.source-han-serif-simplified-chinese
        pkgs.source-han-sans-traditional-chinese
        pkgs.source-han-serif-traditional-chinese
      ];
    };
  };
}
