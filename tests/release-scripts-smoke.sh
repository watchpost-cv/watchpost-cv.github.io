#!/bin/sh
set -eu
for name in install download update agent-install agent-download agent-update; do
  sh -n "content/$name.sh"
  cmp "content/$name.sh" "public/$name.sh"
done
grep -q 'github.com/watchpost-cv/watchpost/releases' content/download.sh
grep -q 'github.com/watchpost-cv/watchpost-agent/releases' content/agent-download.sh
grep -q 'sha256' content/download.sh
grep -q 'sha256' content/agent-download.sh
echo 'watchpost release scripts smoke: ok'
