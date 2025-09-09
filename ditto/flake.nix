{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    pkgsPersonal.url = "github:EdvardSire/nixpkgs/dc6b3d3775457d507e130aa6f2eba582d90b23ce";
  };
  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.ditto = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix ];
    };
  };
}

