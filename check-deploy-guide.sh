#!/bin/sh
# Deterministic checks for the Watchpost company-subdomain deployment guide.
set -eu

page=content/docs/company-deployment.html
generated=public/docs/company-deployment.html

grep -q 'watchpost.company.com' "$page"
grep -q 'cortex.company.com' "$page"
grep -q 'warden.company.com' "$page"
grep -q 'trestle.company.com' "$page"
grep -q 'Caddy' "$page"
grep -q 'nginx' "$page"
grep -q '/healthz' "$page"
grep -q '127.0.0.1:7334' "$page"
grep -q 'independently' "$page"
grep -q 'Type: A' "$page"
grep -q 'Type: CNAME' "$page"
grep -q 'WATCHPOST_SETUP_TOKEN' "$page"
grep -q 'ssh -L 7335:127.0.0.1:7335' "$page"

# The Agent trust boundary must never be described as safely public by default.
grep -q 'must not be casually exposed' "$page"
grep -q '127.0.0.1 only' "$page"
grep -q 'experimental' "$page"
if grep -qi 'safe to expose.*agent.*public\|expose.*agent.*publicly' "$page"; then
  echo "Agent described as safely public" >&2
  exit 1
fi

for leftover in '@pathto' '@input' '@include'; do
  if grep -q "$leftover" "$generated"; then
    echo "generated output contains unresolved $leftover" >&2
    exit 1
  fi
done
grep -q 'watchpost.company.com' "$generated"

echo "watchpost deploy-guide check: ok (watchpost.company.com, /healthz, agent trust boundary)"