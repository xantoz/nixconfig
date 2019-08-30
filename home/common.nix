{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.file = {
    ".zile".source = builtins.path { name = "dotzile"; path = ./config/dotfiles/src/.zile; };
    ".config/youtube-dl/config".source = ./config/dotfiles/src/youtube-dl/config;
    ".config/feh/themes".source = ./config/dotfiles/src/feh/themes;
    ".config/redshift.conf".source = ./config/dotfiles/src/redshift.conf;

    ".config/nixpkgs/config.nix".source = pkgs.writeText "unfree_for_nix-shell" ''
      { allowUnfree = true; }
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

      alias dush='du -sh * | sort -h'

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

      alias mount-patchouli='sshfs -o reconnect patchouli:/ /mnt/patchouli'

      export PATH="$HOME/.local/bin:$PATH"

      export EDITOR='emacsclient -t'
    '';
  };
}
