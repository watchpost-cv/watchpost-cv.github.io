#!/usr/bin/env bash
# CSS contract check for public/assets/css/style.css.
#
# Guards the shared heading typography selector group and the documentation
# overflow rule against accidental mechanical edits. A previous string
# replacement turned ".hero h1,.page-hero h1,.docs-content h1{...}" into
# ".hero h1,.page-hero h1,.docs-content{overflow-x:clip}", stripping heading
# typography from the homepage and ordinary page heroes.
set -u
CSS="public/assets/css/style.css"
if [ ! -f "$CSS" ]; then
  echo "FAIL stylesheet $CSS not found"; exit 1
fi
fail=0
check() {
  if grep -qF "$2" "$CSS"; then
    echo "ok   $1"
  else
    echo "FAIL $1"; fail=1
  fi
}
check "docs-content receives overflow-x:clip" '.docs-content{overflow-x:clip}'
check "three-heading selector group still exists" '.hero h1,.page-hero h1,.docs-content h1{'
check "heading group carries the shared typography" '.hero h1,.page-hero h1,.docs-content h1{letter-spacing:-.055em;line-height:1;margin:16px 0 25px}'
check "hero h1 retains its font-size rule" '.hero h1{font-size:clamp(52px,8vw,96px)'
check "page-hero h1 retains its font-size rule" '.page-hero h1{font-size:clamp(48px,7vw,76px)}'
if grep -qF '.hero h1,.page-hero h1,.docs-content{' "$CSS"; then
  echo "FAIL heading group polluted by bare .docs-content"; fail=1
else
  echo "ok   heading group is not polluted by bare .docs-content"
fi
exit "$fail"
