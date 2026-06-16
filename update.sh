#!/usr/bin/env bash
set -euo pipefail

echo "Updating flake inputs..."
nix flake update

rev=$(nix flake metadata --json | jq -r '.locks.nodes."lean-ctx".locked.rev // .locks.nodes."lean-ctx-src".locked.rev')
if [ "$rev" != "null" ] && [ -n "$rev" ]; then
  short_rev=${rev:0:7}
  echo "Updating version in flake.nix to 0.1.0-$short_rev..."
  sed -i "s/version = \".*\"/version = \"0.1.0-$short_rev\"/" flake.nix
fi

echo "Done."
