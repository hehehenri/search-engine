{ pkgs, serverPackage }:

with pkgs;
with pkgs.ocamlPackages;
mkShell {
  inputsFrom = [ serverPackage ];
  packages = [
    # formatters
    nixfmt
    ocamlformat

    # dev tooling
    ocaml
    dune_3
    ocaml-lsp

    nodejs
    nodePackages.npm
  ];
}
