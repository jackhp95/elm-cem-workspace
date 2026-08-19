#!/usr/bin/env bash
# TypedHtml acid: good must compile, bad must fail. ELM overrides compiler.
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ELM=${ELM:-"$SCRIPT_DIR/../node_modules/.bin/elm"}
cd "$(dirname "$0")"
pass=0; fail=0
expect() {
    local want="$1" file="$2" got
    if "$ELM" make "$file" --output=/dev/null >/tmp/th-verify.out 2>&1; then got=ok; else got=err; fi
    if [ "$want" = "$got" ]; then echo "PASS ($want)  $file"; pass=$((pass+1));
    else echo "FAIL (want $want, got $got)  $file"; sed -n '1,25p' /tmp/th-verify.out; fail=$((fail+1)); fi
}
expect ok src/Good.elm
for f in bad/*.elm; do expect err "$f"; done
echo "----"; echo "$pass passed, $fail failed"; exit $fail
