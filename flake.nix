{
  inputs = {
    nixpkgs.url = "nixpgks/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    adidoks.url = "github:aaranxu/adidoks";
  };

  outputs = { self, nixpkgs, zola, adidoks, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in
        {
          devShell = pkgs.mkShell {
            shellHook = ''
            '';
          };
        });

}
