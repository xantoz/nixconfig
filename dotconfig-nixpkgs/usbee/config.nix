{ pkgs, ...}:

{
  allowUnfree = true;

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
      ]}:'$LD_LIBRARY_PATH
      export LIBVA_DRIVERS_PATH='${pkgs.vaapiIntel}/lib/dri'
      exec ${pkgs.mpv}/bin/mpv "$@"
    '';

    my_webmacs = pkgs.writeShellScriptBin "webmacs" ''
      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.mesa_drivers}/lib:'$LD_LIBRARY_PATH
      export QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/lib/qt-${builtins.concatStringsSep "." (pkgs.lib.take 2 (builtins.splitVersion pkgs.qt5.qtbase.version))}/plugins'
      exec ${pkgs.webmacs}/bin/webmacs "$@"
    '';

    my_mpc-qt = pkgs.writeShellScriptBin "mpc-qt" ''
      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.mesa_drivers}/lib':$LD_LIBRARY_PATH
      export QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/lib/qt-${builtins.concatStringsSep "." (pkgs.lib.take 2 (builtins.splitVersion pkgs.qt5.qtbase.version))}/plugins'
      exec ${pkgs.mpc-qt}/bin/mpc-qt "$@"
    '';

    my_vainfo = pkgs.writeShellScriptBin "vainfo" ''
      export LIBVA_DRIVERS_PATH='${pkgs.vaapiIntel}/lib/dri'
      exec ${pkgs.libva-utils}/bin/vainfo "$@"
    '';

    # my_pulseview = pkgs.writeShellScriptBin "pulseview" ''
    #   export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
    #   export LD_LIBRARY_PATH='${pkgs.mesa_drivers}/lib':$LD_LIBRARY_PATH
    #   export QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/lib/qt-${builtins.concatStringsSep "." (pkgs.lib.take 2 (builtins.splitVersion pkgs.qt5.qtbase.version))}/plugins'
    #   export PYTHONHASHSEED=0
    #   export PYTHONNOUSERSITE=1
    #   export PYTHONPATH="$(nix-shell -p python3 --run 'echo $PYTHONPATH')"   # lolololol
    #   exec ${pkgs.pulseview}/bin/pulseview "$@"
    # '';

    my_pulseview = pkgs.writeScriptBin "pulseview" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p python3

      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.mesa_drivers}/lib'""''${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH
      QTVERSION='qt-${builtins.concatStringsSep "." (pkgs.lib.take 2 (builtins.splitVersion pkgs.qt5.qtbase.version))}'
      # TODO: probably needs to be recursive...
      for i in $(cat ${pkgs.pulseview}/nix-support/propagated-user-env-packages | tr ' ' '\n' | sort | uniq); do
          export QT_PLUGIN_PATH="$QT_PLUGIN_PATH''${QT_PLUGIN_PATH:+:}$i/lib/$QTVERSION/plugins/"
      done
      exec ${pkgs.pulseview}/bin/pulseview "$@"
    '';

    my_dolphin = pkgs.writeShellScriptBin "dolphin" ''
      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.mesa_drivers}/lib'""''${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH
      QTVERSION='qt-${builtins.concatStringsSep "." (pkgs.lib.take 2 (builtins.splitVersion pkgs.qt5.qtbase.version))}'
      # TODO: probably needs to be recursive...
      for i in $(cat ${pkgs.dolphin}/nix-support/propagated-user-env-packages | tr ' ' '\n' | sort | uniq); do
          export QT_PLUGIN_PATH="$QT_PLUGIN_PATH''${QT_PLUGIN_PATH:+:}$i/lib/$QTVERSION/plugins/"
      done
      exec ${pkgs.dolphin}/bin/dolphin "$@"
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

    nixQt = pkgs.writeShellScriptBin "nixQt" ''
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
      export QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/lib/qt-${builtins.concatStringsSep "." (pkgs.lib.take 2 (builtins.splitVersion pkgs.qt5.qtbase.version))}/plugins'
      exec "$@"
    '';

    all = pkgs.buildEnv {
      name = "all";

      paths = [
        pkgs.my_mpv
        pkgs.my_webmacs
        pkgs.emacs26
        pkgs.my_pulseview

        pkgs.nixGLIntel
        pkgs.nixIntel
        pkgs.nixQt

        pkgs.xterm
        pkgs.youtube-dl

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
