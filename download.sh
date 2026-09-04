#!/bin/sh
set -eu
version=${WATCHPOST_VERSION:-latest}; output=watchpost; force=false
while [ "$#" -gt 0 ]; do case "$1" in --version) shift; version=${1:?version required};; --output) shift; output=${1:?output required};; --force) force=true;; --help) echo 'usage: download.sh [--version VERSION] [--output PATH] [--force]'; exit 0;; *) echo "unknown option: $1" >&2; exit 2;; esac; shift; done
case $(uname -s) in Linux) os=linux;; Darwin) os=darwin;; *) echo 'Use a Windows release asset on this platform.' >&2; exit 1;; esac
case $(uname -m) in x86_64|amd64) arch=amd64;; arm64|aarch64) arch=arm64;; *) echo 'Unsupported architecture.' >&2; exit 1;; esac
if [ "$version" = latest ]; then version=$(curl --proto '=https' --tlsv1.2 -fsSL https://api.github.com/repos/watchpost-cv/watchpost/releases/latest | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -1); fi
[ -n "$version" ] || { echo 'Could not resolve the latest Watchpost release.' >&2; exit 1; }
if [ -e "$output" ] || [ -L "$output" ]; then $force || { echo "Refusing to overwrite $output; pass --force." >&2; exit 1; }; fi
asset="watchpost-${version}-${os}-${arch}"; base="https://github.com/watchpost-cv/watchpost/releases/download/$version"; tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT INT TERM
curl --proto '=https' --tlsv1.2 -fsSL "$base/$asset" -o "$tmp/$asset"; curl --proto '=https' --tlsv1.2 -fsSL "$base/SHA256SUMS" -o "$tmp/SHA256SUMS"
expected=$(awk -v f="$asset" '$2==f {print $1}' "$tmp/SHA256SUMS"); [ -n "$expected" ] || { echo 'Checksum entry missing.' >&2; exit 1; }; if command -v sha256sum >/dev/null 2>&1; then actual=$(sha256sum "$tmp/$asset" | awk '{print $1}'); else actual=$(shasum -a 256 "$tmp/$asset" | awk '{print $1}'); fi; [ "$actual" = "$expected" ] || { echo 'Checksum mismatch.' >&2; exit 1; }
chmod 0755 "$tmp/$asset"; mv "$tmp/$asset" "$output"; echo "Downloaded Watchpost $version to $output"
