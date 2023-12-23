{ pkgs, serverPackage }:

with pkgs;
with pkgs.ocamlPackages;
mkShell {
  inputsFrom = [ serverPackage ];
  packages = [
    # server tooling
    ocaml
    dune_3
    ocaml-lsp
    ocamlformat

    # client tooling
    nodejs
    nodePackages.npm
    nodePackages.svelte-language-server
    nodePackages."@tailwindcss/language-server"
    nodePackages.typescript-language-server
  ];
}
