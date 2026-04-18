#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
flake_file="$repo_root/flake.nix"

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

replace_attr() {
  local name="$1"
  local value="$2"
  perl -0pi -e "s#${name} = \".*?\";#${name} = \"$value\";#;" "$flake_file"
}

require gh
require nix
require perl
require sed
require mktemp

latest_tag="${1:-$(gh api repos/yvgude/lean-ctx/releases/latest --jq .tag_name)}"
version="${latest_tag#v}"
rev="$(gh api "repos/yvgude/lean-ctx/git/ref/tags/${latest_tag}" --jq .object.sha)"
src_url="https://github.com/yvgude/lean-ctx/archive/${rev}.tar.gz"

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

src_hash="$(
  nix store prefetch-file --json --unpack "$src_url" \
    | sed -n 's/.*"hash":"\([^"]*\)".*/\1/p'
)"

if [[ -z "$src_hash" ]]; then
  echo "failed to prefetch source hash" >&2
  exit 1
fi

replace_attr version "$version"
replace_attr rev "$rev"
replace_attr hash "$src_hash"
replace_attr cargoHash "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

build_log="$tmpdir/build.log"
if nix build "$repo_root#default" >"$tmpdir/build.out" 2>"$build_log"; then
  echo "cargoHash already valid"
else
  cargo_hash="$(sed -n 's/.*got:[[:space:]]*//p' "$build_log" | tail -n 1)"
  if [[ -z "$cargo_hash" ]]; then
    echo "failed to derive cargoHash from nix build output" >&2
    cat "$build_log" >&2
    exit 1
  fi
  replace_attr cargoHash "$cargo_hash"
fi

nix build "$repo_root#default" >/dev/null

echo "Updated lean-ctx to ${latest_tag} (${rev})"
