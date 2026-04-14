#!/usr/bin/env bash
# Verify every `just <recipe>` mentioned in README.md or docs/*.md
# corresponds to a real recipe in the Justfile.
#
# Catches: recipes renamed/removed without updating docs, and typos
# in docs (e.g. 'just phmr_run' vs 'just phmr-run').
set -euo pipefail

RECIPES=$(just --summary | tr ' ' '\n' | sort -u)

# Extract `just <name>` mentions that are either:
#   - inline-code: `just foo` (backtick-delimited)
#   - at the start of a code-fence line: starting a bash command
# This avoids false positives from English prose like "just add" or "just for".
MENTIONS=$(
    {
        grep -rhoE '`just [a-z][a-z0-9-]+' README.md docs/ 2>/dev/null || true
        grep -rhE '^[[:space:]]*just [a-z][a-z0-9-]+' README.md docs/ 2>/dev/null || true
    } \
        | sed -E 's/^[[:space:]]*`?just +//' \
        | awk '{print $1}' \
        | sort -u
)

MISSING=()
for name in $MENTIONS; do
    if ! grep -qxF "$name" <<<"$RECIPES"; then
        MISSING+=("$name")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "ERROR: docs reference recipes that don't exist in the Justfile:" >&2
    for name in "${MISSING[@]}"; do
        echo "  - just $name" >&2
        grep -rn "just $name" README.md docs/ 2>/dev/null | sed 's/^/      /' >&2
    done
    exit 1
fi

echo "OK: all 'just <recipe>' mentions in docs match real Justfile recipes."
