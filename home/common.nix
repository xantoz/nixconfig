{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = import ./modules/module-list.nix;

  # Prevent home-manager from controlling the KB
  home.keyboard = null;

  programs.bash = {
    shellOptions = [
      "histappend" # Append to history file rather than replacing it.
      "cmdhist" # Save multiline commands as one entry

      # Below are ones that I didn't use to use, but that were in the
      # defaults in the bash home-manager module

      # check the window size after each command and, if
      # necessary, update the values of LINES and COLUMNS.
      "checkwinsize"

      # Extended globbing.
      "extglob"
      "globstar"

      # Warn if closing shell with running jobs.
      "checkjobs"
    ];
    # TODO: HISTTIMEFORMAT should maybe be added to the module itself?
    # TODO: historyControl in the bash module does not support the ignoreboth option!
    # TODO: should prompt command also be added to the module?
    bashrcExtra = ''
      export HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S - '
      PROMPT_COMMAND='history -a;history -n'
      export HISTCONTROL=ignoreboth
    '';
    historySize = 600000;
    historyFileSize = 600000;
    initExtra = ''
      alias dush='du -sh -- * | sort -h'

      0x0()
      {
          curl -F"file=@$1" https://0x0.st
      }

      build_cscope()
      {
          find `pwd` -type f -iname '*.[ch]' -print > cscope.files
          IFS=$'\n' etags $(< cscope.files)
          cscope -qbi cscope.files
      }

      fingerprints()
      {
          local file="''${1:-$HOME/.ssh/authorized_keys}"
          while read l; do
          [[ -n $l && ''${l###} = $l ]] && ssh-keygen -l -f /dev/stdin <<<$l
          done < "''${file}"
      }

      alias mount-patchouli='sshfs -o reconnect patchouli:/ /mnt/patchouli'

      export PATH="$HOME/.local/bin:$PATH"

      export EDITOR='emacsclient -t'
    '';
  };

  home.file = {
    ".zile".source = builtins.path { name = "dotzile"; path = ./config/dotfiles/src/.zile; };
    ".config/youtube-dl/config".source = ./config/dotfiles/src/youtube-dl/config;
    ".config/feh/themes".source = ./config/dotfiles/src/feh/themes;
    ".config/redshift.conf".source = ./config/dotfiles/src/redshift.conf;

    ".config/alacritty".source = ./config/dotfiles/src/alacritty;
    ".config/kitty".source = ./config/dotfiles/src/kitty;

    ".config/mako".source = ./config/dotfiles/src/mako;

    ".config/waybar".source = ./config/dotfiles/src/waybar;

    ".config/pqivrc".source = pkgs.writeText "pqiv-config" ''
      [options]
      fullscreen=1
      sort=1
    '';

    ".config/nixpkgs/config.nix".source = pkgs.writeText "unfree_for_nix-shell" ''
      { allowUnfree = true; }
    '';
  };

  home.stateVersion = "22.05";
}
