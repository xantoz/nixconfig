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
  };
}
