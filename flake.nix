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
        rec {

          defaultPackage = nb-docs;
          nb-docs = pkgs.stdenv.mkDerivation {
            name = "nb-docs";
            src = ./.;
            buildInputs = [pkgs.zola];
            buildPhase = ''
              mkdir -p $out
              cp -r $src/* $out/
              cd $out

              mkdir -p themes/adidoks
              ls ${adidoks}
              cp -r ${adidoks}/* themes/adidoks/
              zola build
            '';

            installPhase = ''
              mkdir -p $out
              cp -r public/* $out/
            '';
          };

          packages.container = pkgs.dockerTools.buildImage {
            name = "nb-docs";
            created = "now";
            tag = "latest";
            contents = pkgs.buildEnv {
              name = "image-root";
              paths = [
                pkgs.cacert
                pkgs.python3
                nb-docs
              ];
              pathsToLink = [ "/public" "/bin" ];
            };
            config = {
              Cmd = [ "python3" "-m" "http.server" "8000" "--directory" "public" ];
            };
          };

          devShell = pkgs.mkShell {
            buildInputs = [ pkgs.zola ];
            shellHook = ''
              rm -rf ./themes/adidoks
              mkdir -p themes
              ln -s ${adidoks} ./themes/adidoks
            '';
          };
        });

}
