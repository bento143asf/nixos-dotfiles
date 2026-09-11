{
  description = "My personal NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.g15 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./Nix/configuration.nix
      ];
    };
  };
}
