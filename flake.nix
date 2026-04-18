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
          version = "3.2.5";

          src = pkgs.fetchFromGitHub {
            owner = "yvgude";
            repo = "lean-ctx";
            rev = "f118538ad7035beaf6b40945a273c8b5c4d8b375";
            hash = "sha256-3jGOSM35sk3V52t/ZZ31C13czm/cBqmv/+kfE+1DaYU=";
          };

          sourceRoot = "source/rust";

          cargoHash = "sha256-NKAWhxt5Re+KdImCV48hfRXQVDomGvAhW2G+PRNPM/I=";

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
