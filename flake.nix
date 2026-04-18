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
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "lean-ctx";
          version = "3.0.3";

          src = pkgs.fetchFromGitHub {
            owner = "yvgude";
            repo = "lean-ctx";
            rev = "8f0eb122907a6cb0fe7d104988751dbe8fb5e68a";
            hash = "sha256-uhA5WaGwEPfqQ4vw/F3yBzFQ9MPeqcX4eljZHLJfHS4=";
          };

          sourceRoot = "source/rust";

          cargoHash = "sha256-iINXOfObgEMuMpvry8GOjLvIV0I+CXdO/rNHlnUIh98=";

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
