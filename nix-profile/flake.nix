{
  description = "Packages";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };
  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { 
              inherit system; 
              config = {};
          };
          plotjuggler = pkgs.callPackage ./plotjuggler.nix { };
        in
        {
          default = pkgs.buildEnv {
            name = "package env";
            paths = (with pkgs; [
              plotjuggler
              ]);
          };
        }
      );
    };
}

