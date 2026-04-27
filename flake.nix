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
          rev = "2eafcfeb26f2b8cdbacfe879704d2182824876b5";
          hash = "sha256-AEqbHlyQr9Xf5twk9Q+l4WuQhbRyoo3SohiMPMzBdBg=";
        };
        packageSrc = pkgs.runCommand "lean-ctx-3.2.8-src" { } ''
          mkdir -p "$out"
          cp -R ${upstreamSrc}/rust/. "$out/"
        '';
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "lean-ctx";
          version = "3.4.3";

          src = packageSrc;

          cargoHash = "sha256-4FoAu5isthCKHXqc3AtYP/5CSnAHGJymgCYBVGmhn3Y=";

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
