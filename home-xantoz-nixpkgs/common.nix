{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (import ../overlays/local/pkgs/default.nix)
  ];

  home.file = {
    ".screenrc".source = builtins.path { name = "dotscreenrc"; path = ./config/dotfiles/src/.screenrc; };
    ".zile".source = builtins.path { name = "dotzile"; path = ./config/dotfiles/src/.zile; };
    ".config/youtube-dl/config".source = ./config/dotfiles/src/youtube-dl/config;
    ".config/feh/themes".source = ./config/dotfiles/src/feh/themes;
    ".config/redshift.conf".source = ./config/dotfiles/src/redshift.conf;

    ".config/nixpkgs/config.nix".source = pkgs.writeText "unfree_for_nix-shell" ''
      { allowUnfree = true; }
    '';
  };
}
