{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    adidoks = {
      url = "github:aaranxu/adidoks";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, adidoks }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in
        {
          devShell = pkgs.mkShell {
            buildInputs = [ pkgs.zola ];
            shellHook = ''
              rm -rf ./themes/adidoks
              ln -s ${adidoks} ./themes/adidoks
            '';
          };
        });

}
