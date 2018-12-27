{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./emacs.nix
    ./desktop.nix
  ];

  # home.packages = with pkgs; [
  # ];

  programs.bash.enable = true;
  home.sessionVariables.LESS = "-R";

  home.file =
  {
    ".config/emacs".source = ./config/emacs;
    ".emacs".source = pkgs.writeText "dotemacs" ''
      (load "~/.config/emacs/init.el")
    '';

    ".config/ratpoison".source = ./config/ratpoison;
    ".ratpoisonrc".source = pkgs.writeText "dotratpoisonrc" ''
      exec ratpoison -c "source $HOME/.config/ratpoison/ratpoisonrc"
      exec ratpoison -c "source $HOME/.config/ratpoison/backlightrc"
      exec ratpoison -c "source $HOME/.config/ratpoison/volumerc"
    '';

    ".config/xterm".source = ./config/xterm;
    ".Xresources".source = pkgs.writeText "dotXresources" ''
        #define XTERM_URL_COMMANDS           \
              "webmacs '%URL%'"              \
              "firefox '%URL%'"              \
              "mpv '%URL%'"                  \
              "echo -n '%URL%' | xsel -i"    \
              "xterm -e \\\"youtube-dl -o '/tmp/%(title)s.%(ext)s' '%URL%'\\\""
        #include ".config/xterm/Xresources"
    '';

    # lib.elemAt (builtins.filter (u: u.isNormalUser) (lib.attrValues config.users.users)) 0

    ".xinitrc".source = pkgs.writeText "dotxinitrc" ''
      xrdb -merge ~/.Xresources

      xinput set-prop 'PS/2 Generic Mouse' 'libinput Middle Emulation Enabled' 1

      exec ratpoison
    '';

    ".bashrc".source = pkgs.writeText "dotbashrc" ''
      export HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S - '
      shopt -s histappend
      shopt -s cmdhist
      shopt -s histverify
      HISTSIZE=600000
      HISTFILESIZE=600000
      PROMPT_COMMAND='history -a;history -n'
      export HISTCONTROL=ignoreboth

      build_cscope()
      {
          find `pwd` -type f -iname '*.[ch]' -print > cscope.files
          IFS=$'\n' etags $(< cscope.files)
          cscope -qbi cscope.files
      }
    '';

  };
}
