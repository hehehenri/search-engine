{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    ocaml-overlays.url = "github:nix-ocaml/nix-overlays";
    ocaml-overlays.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, flake-utils, nixpkgs, ocaml-overlays }:
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ocaml-overlays.overlays.default ];
        };
      in with pkgs; rec {
        devShells.default = mkShell {
          inputsFrom = [ packages.default ];
          buildInputs = [
            ocamlPackages.merlin
            ocamlformat
            ocamlPackages.ocp-indent
            ocamlPackages.utop
          ];
        };

        packages.default = ocamlPackages.buildDunePackage rec {
          pname = "search_engine";
          version = "0.0.1";
          useDune2 = true;
          src = ./.;
          buildInputs = with ocamlPackages; [ 
            ppx_deriving
            integers
            piaf
            data-encoding
            utop
            re
            caqti
            caqti-driver-postgresql
            ppx_rapper
            routes
            jose
            ppx_deriving_yojson
            ppx_deriving_cmdliner
          ];
          nativeBuildInputs = [ makeBinaryWrapper ];

          postFixup = ''
            wrapProgram $out/bin/search_engine --prefix PATH : ${
              lib.makeBinPath [ btrfs-progs openssh ]
            }
          '';

          meta = { homepage = "https://github.com/hnrbs/search-engine"; };
        };
      });

}
