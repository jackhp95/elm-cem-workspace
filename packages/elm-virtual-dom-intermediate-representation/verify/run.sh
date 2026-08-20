#!/usr/bin/env bash
# Oracle harness for the IR: good cases must compile, bad cases must fail,
# AttackForge must compile (the documented lint-fence reality).
# Usage: ./run.sh   (ELM env var overrides the compiler path)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
# Absolute, and resolved BEFORE the cd below: a relative default broke when the
# script was invoked from the repo root, and a missing compiler made every
# bad-case "pass" (nothing compiles, so everything looks like the wanted `err`).
ELM=${ELM:-"$HERE/../node_modules/.bin/elm"}
if ! command -v "$ELM" >/dev/null 2>&1 && [ ! -x "$ELM" ]; then
    echo "no elm compiler at '$ELM' — run 'npm install' or set ELM=/path/to/elm" >&2
    exit 1
fi
cd "$HERE"
mkdir -p out
pass=0
fail=0

expect() { # expect <ok|err> <file>
    local want="$1" file="$2"
    local name got
    name=$(basename "$file" .elm)
    if "$ELM" make "$file" --output=/dev/null >"out/$name.txt" 2>&1; then
        got=ok
    else
        got=err
    fi
    if [ "$want" = "$got" ]; then
        echo "PASS (want $want)  $file"
        pass=$((pass + 1))
    else
        echo "FAIL (want $want, got $got)  $file"
        sed -n '1,30p' "out/$name.txt"
        fail=$((fail + 1))
    fi
}

expect ok src/Good.elm
expect ok src/InferNoAnno.elm
expect ok src/AttackForge.elm
expect err bad/OptionInDiv.elm
expect err bad/WrongSlotKind.elm
expect err bad/WrongEnumString.elm
expect err bad/WrongEnumToken.elm
expect err bad/EventOnDiv.elm
expect err bad/CtxSpoof.elm
expect err bad/AttackNoInternal.elm

echo "----"
echo "$pass passed, $fail failed (bad-case error texts in verify/out/)"
exit "$fail"
