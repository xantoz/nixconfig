{ pkgs, ...}:

let
  /*
  ** Wraps binary for GL, Vulkan and VAAPI paths suitable for intel iGPUs.
  ** Probably adds slightly too much to LD_LIBRARY_PATH, but whatever
  */
  nixIntelWrap = package: name: binaries:
    pkgs.symlinkJoin {
        name = name;
        paths = [ package ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          for binary in ${pkgs.lib.concatStringsSep " " binaries}; do
              wrapProgram "$out$binary"                                     \
                --set LIBGL_DRIVERS_PATH "${pkgs.mesa_drivers}/lib/dri"     \
                --set LIBVA_DRIVERS_PATH '${pkgs.vaapiIntel}/lib/dri'       \
                --prefix LD_LIBRARY_PATH ":" ${pkgs.lib.makeLibraryPath [
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
                  ]}
          done
        '';
    };

  /*
  ** Same as above, but also wraps python
  */
  nixIntelPythonWrap = package: name: binaries:
    pkgs.symlinkJoin {
        name = name;
        paths = [ package ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          for binary in ${pkgs.lib.concatStringsSep " " binaries}; do
              wrapProgram "$out$binary"                                     \
                --set PYTHONNOUSERSITE 1                                    \
                --set PYTHONHASHSEED 0                                      \
                --prefix PYTHONPATH : "${pkgs.python3}/lib/${pkgs.python3.libPrefix}/site-packages" \
                --set LIBGL_DRIVERS_PATH "${pkgs.mesa_drivers}/lib/dri"     \
                --set LIBVA_DRIVERS_PATH '${pkgs.vaapiIntel}/lib/dri'       \
                --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
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
                  ]}
          done
        '';
    };
in
{
  allowUnfree = true;

  nix.maxJobs = 4;

  packageOverrides = pkgs_: {

    my_mpv = nixIntelWrap pkgs.mpv "mpv" [ "/bin/mpv" "/bin/umpv" ];

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

    my_kitty = pkgs.writeShellScriptBin "kitty" ''
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
      exec ${pkgs.kitty}/bin/kitty "$@" -e /bin/sh -c "unset LIBGL_DRIVERS_PATH; unset LD_LIBRARY_PATH; unset LIBVA_DRIVERS_PATH; exec $SHELL -l"
    '';

    my_mpc-qt = nixIntelWrap pkgs.mpc-qt "mpc-qt" [ "/bin/mpc-qt" ];

    my_webmacs = nixIntelWrap pkgs.webmacs "webmacs" [ "/bin/webmacs" ];

    my_vainfo = nixIntelWrap pkgs.vainfo "vainfo" [ "/bin/vainfo" ];

    my_pulseview = pkgs.writeScriptBin "pulseview" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p python3

      export LIBGL_DRIVERS_PATH='${pkgs.mesa_drivers}/lib/dri'
      export LD_LIBRARY_PATH='${pkgs.mesa_drivers}/lib'""''${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH
      exec ${pkgs.pulseview}/bin/pulseview "$@"
    '';

    /*
    my_pulseview = nixIntelPythonWrap pkgs.pulseview "pulseview" [ "/bin/pulseview" ];
    */

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
        # pkgs.my_mpc-qt
        pkgs.my_mpv
        pkgs.my_webmacs

        pkgs.qt5.qtbase # need this or Qt apps don't have any platform backends for some stupid reason
        pkgs.qt5.qtwayland # same but for wayland
        pkgs.emacs27

        pkgs.my_pulseview
        pkgs.my_alacritty
        pkgs.my_kitty

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

        pkgs.google-drive-ocamlfuse

        pkgs.nix-prefetch-github

        pkgs.black  # because ubuntu black is outdated

        # Ubuntu waybar doesn't include the clock module for some reason (also nix waybar is a bit newer).
        # (TODO: consider using nix sway again?)
        pkgs.waybar

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
