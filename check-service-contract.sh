#!/bin/sh
# Deterministic service-contract checks for the Watchpost site.
set -eu

page=content/docs/deployment.html
verification=content/docs/verification.html
generated=public/docs/deployment.html

for cmd in 'service install' 'service start' 'service stop' 'service restart' 'service status' 'service logs' 'service uninstall'; do
  grep -q "$cmd" "$page"
done
grep -q 'enabled-runtime' "$page"
grep -q 'runtime-only enablement' "$page"
grep -q 'without leaving a persistent link' "$page"
grep -q 'unmask' "$page"
grep -q 'Uninstall removes the service registration and preserves Watchpost data' "$page"
grep -q 'WantedBy=multi-user.target' "$page"
grep -q 'does not depend on any user login' "$page"
grep -q 'root-owned <code>0600</code>' "$page"

# Shared host/port configuration pattern: canonical --host/--port install
# example, fresh loopback default, legacy form retained, and the recorded
# listener surviving restart/reboot.
grep -q 'service install --host 127.0.0.1 --port 7404' "$page"
grep -q '127.0.0.1:7334' "$page"
grep -q -- '--listen' "$page"
grep -q 'recorded listener is the runtime listener across restart and reboot' "$page"

# Agent host/port pattern: the separate Watchpost Agent records canonical
# --host/--port in its unit and defaults to loopback 127.0.0.1:7335, with the
# WATCHPOST_AGENT_HOST/WATCHPOST_AGENT_PORT environment and legacy --listen
# retained.
grep -q 'watchpost-agent service install --host 127.0.0.1 --port 7405' "$page"
grep -q '127.0.0.1:7335' "$page"
grep -q 'WATCHPOST_AGENT_HOST' "$page"
grep -q 'WATCHPOST_AGENT_LISTEN' "$page"

# Verification page: model-based service evidence, no unsupported live claim.
grep -q 'stateful layered fake-systemd transaction model' "$verification"
grep -q 'has not been proven through an actual host reboot or against every systemd release' "$verification"
if grep -qiE 'battle-proven on every supported operating system|validated against every systemd release|production-proven rollback' "$verification"; then
  echo "verification page overclaims live systemd evidence" >&2
  exit 1
fi

grep -q 'enabled-runtime' "$generated"
echo "watchpost service-contract check: ok"