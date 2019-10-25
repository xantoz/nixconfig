{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = import ./modules/module-list.nix;

  home.file = {
    ".zile".source = builtins.path { name = "dotzile"; path = ./config/dotfiles/src/.zile; };
    ".config/youtube-dl/config".source = ./config/dotfiles/src/youtube-dl/config;
    ".config/feh/themes".source = ./config/dotfiles/src/feh/themes;
    ".config/redshift.conf".source = ./config/dotfiles/src/redshift.conf;

    ".config/alacritty".source = ./config/dotfiles/src/alacritty;
    ".config/kitty".source = ./config/dotfiles/src/kitty;

    ".config/nixpkgs/config.nix".source = pkgs.writeText "unfree_for_nix-shell" ''
      { allowUnfree = true; }
    '';

    ".bashrc".source = pkgs.writeText "dotbashrc" ''
      export HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S - '
      shopt -s histappend
      shopt -s cmdhist
      HISTSIZE=600000
      HISTFILESIZE=600000
      PROMPT_COMMAND='history -a;history -n'
      export HISTCONTROL=ignoreboth

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
}
