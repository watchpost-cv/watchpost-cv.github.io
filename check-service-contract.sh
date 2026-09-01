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
grep -q 'Uninstall preserves Watchpost data' "$page"
grep -q 'enable-linger' "$page"
grep -q 'never enables .*lingering automatically' "$page"

# Verification page: model-based service evidence, no unsupported live claim.
grep -q 'stateful layered fake-systemd transaction model' "$verification"
grep -q 'has not been proven through destructive live-service failure injection' "$verification"
if grep -qiE 'battle-proven on every supported operating system|validated against every systemd release|production-proven rollback' "$verification"; then
  echo "verification page overclaims live systemd evidence" >&2
  exit 1
fi

grep -q 'enabled-runtime' "$generated"
echo "watchpost service-contract check: ok"