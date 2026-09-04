#!/bin/sh
set -eu
system=false; rollback=false
while [ "$#" -gt 0 ]; do case "$1" in --system) system=true;; --rollback) rollback=true;; --help) echo 'usage: agent-update.sh [--system] [--rollback]'; exit 0;; *) echo "unknown option: $1" >&2; exit 2;; esac; shift; done
if $system; then [ "$(id -u)" -eq 0 ] || { echo '--system requires root.' >&2; exit 1; }; binary=/usr/local/bin/watchpost-agent; else [ "$(id -u)" -ne 0 ] || { echo 'Run without sudo or pass --system.' >&2; exit 1; }; binary=${WATCHPOST_AGENT_INSTALL_DIR:-"$HOME/.local/bin"}/watchpost-agent; fi
[ -f "$binary" ] && [ ! -L "$binary" ] || { echo "No regular Watchpost Agent installation at $binary" >&2; exit 1; }; if $rollback && $system; then "$binary" service rollback; exit 0; fi
previous="$binary.previous"; if $rollback; then [ -f "$previous" ] || { echo 'No rollback binary is available.' >&2; exit 1; }; cp "$previous" "$binary.rollback.$$"; chmod 0755 "$binary.rollback.$$"; mv "$binary.rollback.$$" "$binary"; echo 'Restored the previous Watchpost Agent binary.'; exit 0; fi
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT INT TERM; WATCHPOST_AGENT_VERSION=${WATCHPOST_AGENT_VERSION:-latest} sh -c "curl -fsSL https://watchpost.cv/agent-download.sh | sh -s -- --output '$tmp/watchpost-agent'"
if $system && [ -f /etc/systemd/system/watchpost-agent.service ]; then sha=$(sha256sum "$tmp/watchpost-agent" | awk '{print $1}'); "$binary" service update "$tmp/watchpost-agent" "$sha"; else cp "$binary" "$previous.new"; chmod 0755 "$previous.new"; mv "$previous.new" "$previous"; install -m 0755 "$tmp/watchpost-agent" "$binary.new"; mv "$binary.new" "$binary"; fi
echo 'Updated Watchpost Agent. Roll back with agent-update.sh --rollback.'
