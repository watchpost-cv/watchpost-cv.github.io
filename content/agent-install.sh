#!/bin/sh
set -eu
system=false
while [ "$#" -gt 0 ]; do case "$1" in --system) system=true;; --help) echo 'usage: agent-install.sh [--system]'; exit 0;; *) echo "unknown option: $1" >&2; exit 2;; esac; shift; done
if $system; then [ "$(id -u)" -eq 0 ] || { echo '--system requires root.' >&2; exit 1; }; dir=/usr/local/bin; else [ "$(id -u)" -ne 0 ] || { echo 'Run without sudo or pass --system.' >&2; exit 1; }; dir=${WATCHPOST_AGENT_INSTALL_DIR:-"$HOME/.local/bin"}; fi
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT INT TERM; WATCHPOST_AGENT_VERSION=${WATCHPOST_AGENT_VERSION:-latest} sh -c "curl -fsSL https://watchpost.cv/agent-download.sh | sh -s -- --output '$tmp/watchpost-agent'"
mkdir -p "$dir"; install -m 0755 "$tmp/watchpost-agent" "$dir/watchpost-agent"; echo "Installed Watchpost Agent to $dir/watchpost-agent"
if $system && [ "${WATCHPOST_AGENT_SKIP_SERVICE_INSTALL:-0}" != 1 ] && command -v systemctl >/dev/null 2>&1; then "$dir/watchpost-agent" service install; fi
case ":$PATH:" in *":$dir:"*) ;; *) echo "Add $dir to PATH.";; esac
