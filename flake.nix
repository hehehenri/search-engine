{
  description = "Search Engine Nix Flake";

  inputs = {
    nixpkgs.url = "github:anmonteiro/nix-overlays";
    nix-filter.url = "github:numtide/nix-filter";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nix-filter, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (nixpkgs.makePkgs {
          inherit system;
          extraOverlays = [ ];
        }).extend
          (self: super: { ocamlPackages = super.ocaml-ng.ocamlPackages_5_0; });

        serverPackage = pkgs.callPackage ./nix/server.nix { inherit nix-filter; }; 

        shell = import ./nix/shell.nix { inherit pkgs serverPackage; };
      in 
      rec {
        packages = { inherit serverPackage; };
        devShells.default = shell;
      });
}
