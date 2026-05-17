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
          rev = "abf2b1007124509d1a5714d50942c4da37a9dcb8";
          hash = "sha256-WpO/AkUG57HjKhYDa0aR99oAB6DKNvJ93OphArpYrYk=";
        };
        packageSrc = pkgs.runCommand "lean-ctx-3.2.8-src" { } ''
          mkdir -p "$out"
          cp -R ${upstreamSrc}/rust/. "$out/"
        '';
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "lean-ctx";
          version = "3.6.2";

          src = packageSrc;

          cargoHash = "sha256-Upb7ij4uRW2RpR9WNSICB2CXuh1zH+vgjTPFAVKyYSY=";

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
