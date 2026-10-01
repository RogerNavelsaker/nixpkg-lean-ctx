{
  description = "A flake for building lean-ctx";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://rogernavelsaker.cachix.org"
      "https://nacosolutions.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "rogernavelsaker.cachix.org-1:n1DtzMNhA9Rz4Kg3xlXOi/KceULu8VrMbs9WXyMFQNQ="
      "nacosolutions.cachix.org-1:JzCiW2CLcuLXtwOVAg3SlSK/kpqWbfSFEVenyKVUlug="
    ];
  };


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
          rev = "0330d1e3ebe1782f8ef5f9f29668bad0759f10ce";
          hash = "sha256-EiQZXUmk62SEAvWvqaf+63IuyZprGORJxQLsCEw1L4A=";
        };
        packageSrc = pkgs.runCommand "lean-ctx-3.2.8-src" { } ''
          mkdir -p "$out"
          cp -R ${upstreamSrc}/rust/. "$out/"
        '';
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "lean-ctx";
          version = "3.6.21";

          src = packageSrc;

          cargoHash = "sha256-ptCccBQVkzy9n9pj3NJu+DOjP4q+Ir9YdHufT2TJLhA=";

          nativeBuildInputs = [ pkgs.pkg-config pkgs.perl ];
          buildInputs = [ pkgs.openssl pkgs.zlib ];

          doCheck = false;
          RUSTFLAGS = "-C target-cpu=x86-64";

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