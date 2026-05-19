{
  description = "A flake for building lean-ctx";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        upstreamSrc = pkgs.fetchFromGitHub {
          owner = "yvgude";
          repo = "lean-ctx";
          rev = "925159d297c385f67a3690e6fbdc62fbb1b2b495";
          hash = "sha256-jeFJG/eMFzpEHfparQNgcG7CZi2bH4xIlpB3cn6ygZU=";
        };
        packageSrc = pkgs.runCommand "lean-ctx-3.2.8-src" { } ''
          mkdir -p "$out"
          cp -R ${upstreamSrc}/rust/. "$out/"
        '';
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "lean-ctx";
          version = "3.6.8";

          src = packageSrc;

          cargoHash = "sha256-JD2lZ3BIsBLg3RdD2K3/bhVEX4zZReMKd9luUJ66OmI=";

          nativeBuildInputs = [ pkgs.pkg-config pkgs.perl ];
          buildInputs = [ pkgs.openssl pkgs.zlib ];

          doCheck = false;

          meta = with pkgs.lib; {
            description = "Hybrid Context Optimizer for LLMs";
            homepage = "https://github.com/yvgude/lean-ctx";
            license = licenses.mit;
            mainProgram = "lean-ctx";
          };
        };
      }
    );
}
