#!/bin/sh
set -eu
version=${WATCHPOST_AGENT_VERSION:-latest}; output=watchpost-agent; force=false
while [ "$#" -gt 0 ]; do case "$1" in --version) shift; version=${1:?version required};; --output) shift; output=${1:?output required};; --force) force=true;; --help) echo 'usage: agent-download.sh [--version VERSION] [--output PATH] [--force]'; exit 0;; *) echo "unknown option: $1" >&2; exit 2;; esac; shift; done
[ "$(uname -s)" = Linux ] || { echo 'Watchpost Agent currently supports Linux.' >&2; exit 1; }; case $(uname -m) in x86_64|amd64) arch=amd64;; arm64|aarch64) arch=arm64;; *) echo 'Unsupported architecture.' >&2; exit 1;; esac
if [ "$version" = latest ]; then version=$(curl --proto '=https' --tlsv1.2 -fsSL https://api.github.com/repos/watchpost-cv/watchpost-agent/releases/latest | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -1); fi
[ -n "$version" ] || { echo 'Could not resolve the latest Watchpost Agent release.' >&2; exit 1; }; if [ -e "$output" ] || [ -L "$output" ]; then $force || { echo "Refusing to overwrite $output; pass --force." >&2; exit 1; }; fi
asset="watchpost-agent-${version}-linux-${arch}.tar.gz"; base="https://github.com/watchpost-cv/watchpost-agent/releases/download/$version"; tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT INT TERM
curl --proto '=https' --tlsv1.2 -fsSL "$base/$asset" -o "$tmp/$asset"; curl --proto '=https' --tlsv1.2 -fsSL "$base/SHA256SUMS" -o "$tmp/SHA256SUMS"; (cd "$tmp" && grep "  $asset$" SHA256SUMS | sha256sum -c -)
tar -xzf "$tmp/$asset" -C "$tmp" watchpost-agent; chmod 0755 "$tmp/watchpost-agent"; mv "$tmp/watchpost-agent" "$output"; echo "Downloaded Watchpost Agent $version to $output"
