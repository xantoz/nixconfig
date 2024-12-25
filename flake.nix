{
  description = "My NixOS Config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager"; # or pin to a release if you like
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ self, nixpkgs, home-manager, ... }: let
    inherit (self) outputs;
  in {
    # nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    nixosConfigurations = {
      leon = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs; };
          modules = [ ./machines/leon/configuration.nix ];
        };
    };
  };
}
