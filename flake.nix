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
          rev = "c94864f1acaf8775ec143956e4d558fe2bb91a0c";
          hash = "sha256-ztzF/qQ+QXXvur1tcFF25lA7e/0biLn6nmFwe266AUw=";
        };
        packageSrc = pkgs.runCommand "lean-ctx-3.2.8-src" { } ''
          mkdir -p "$out"
          cp -R ${upstreamSrc}/rust/. "$out/"
        '';
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "lean-ctx";
          version = "3.6.0";

          src = packageSrc;

          cargoHash = "sha256-Fa/fCjoS0iCSPOqq55YGcLCKbkjOncmundm0eUa8qmg=";

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
