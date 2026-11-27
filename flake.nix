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
          rev = "b1a502e27c91f2e588d24bf6deff59556c1ebeb2";
          hash = "sha256-f0CfIKLAvJv/DAwk/n8+HnpjFEY8Fpwkni9YslD51QQ=";
        };
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "lean-ctx";
          version = "3.12.7";

          src = upstreamSrc;
          sourceRoot = "${upstreamSrc.name}/rust";

          cargoHash = "sha256-DCopd5zeP+HT/bG35FR0la2twV3r16FaE6G2sSxy9UA=";

          nativeBuildInputs = [ pkgs.pkg-config pkgs.perl pkgs.cmake ];
          buildInputs = [ pkgs.openssl pkgs.zlib pkgs.zstd pkgs.sqlite ];

          # cargo-setup-hook exports JEMALLOC_OVERRIDE to a nonexistent sentinel path;
          # clear it so tikv-jemalloc-sys builds jemalloc from its vendored source.
          preBuild = ''
            unset JEMALLOC_OVERRIDE AWS_LC_SYS_USE_SYSTEM
          '';

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