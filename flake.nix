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
          rev = "527aca5d41a904efbbc70c006d4f64b1436f2f13";
          hash = "sha256-KaZSf5WDCmcsqnYp5mVMQKse0L9eN+P9OfKZqlwrN3g=";
        };
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "lean-ctx";
          version = "3.12.8";

          src = upstreamSrc;
          sourceRoot = "${upstreamSrc.name}/rust";

          cargoHash = "sha256-aRqlfQ6jDcNPZ0m1pAiatJ6Wl7UOQlYO13xdvpSFTa4=";

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