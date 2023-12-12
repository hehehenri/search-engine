{ pkgs, searchEngine }:

with pkgs;
with pkgs.ocamlPackages;
mkShell {
  inputsFrom = [ searchEngine ];
  packages = [
    # formatters
    nixfmt
    ocamlformat

    # dev tooling
    ocaml
    dune_3
    ocaml-lsp
  ];
}
