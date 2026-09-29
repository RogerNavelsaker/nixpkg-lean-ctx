{ pkgs, ... }:

{
  packages = with pkgs; [
    git
    curl
    jq
    ripgrep
  ];
}
