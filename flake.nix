{
  description = "My NixOS Config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = inputs@{ self, nixpkgs, ...}: {
    # nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    nixosConfigurations.leon = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./machines/leon/configuration.nix ];
#      modules = [ ./configuration.nix ];
    };
  };
}
