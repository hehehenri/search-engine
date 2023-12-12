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
      in let searchEngine = pkgs.callPackage ./nix { inherit nix-filter; };
      in rec {
        packages = { inherit searchEngine; };
        devShell = import ./nix/shell.nix { inherit pkgs searchEngine; };
      });
}
