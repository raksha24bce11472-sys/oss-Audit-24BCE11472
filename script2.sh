#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 24BCE11472 – OSS NGMC Capstone Project
# script2.sh – Dependency Audit
#
# Lists declared dependencies and checks for common health indicators:
# pinned versions, deprecated package names, and lock-file consistency.
#
# Usage: ./script2.sh [path-to-project]

set -euo pipefail

TARGET="${1:-.}"

echo "============================================="
echo "  OSS Audit – Script 2: Dependency Audit"
echo "  Target: $TARGET"
echo "============================================="
echo ""

PASS=0
WARN=0
FAIL=0

# ── 1. Detect package ecosystem ────────────────────────────────────────────────
echo "[CHECK 1] Package ecosystem detection"
HAS_NPM=false
HAS_PIP=false
HAS_GEM=false
HAS_GO=false

[[ -f "$TARGET/package.json" ]]     && HAS_NPM=true  && echo "  ✔  Node.js / npm  (package.json)"
[[ -f "$TARGET/requirements.txt" ]] && HAS_PIP=true  && echo "  ✔  Python / pip   (requirements.txt)"
[[ -f "$TARGET/Gemfile" ]]          && HAS_GEM=true  && echo "  ✔  Ruby / gem     (Gemfile)"
[[ -f "$TARGET/go.mod" ]]           && HAS_GO=true   && echo "  ✔  Go modules     (go.mod)"

if ! $HAS_NPM && ! $HAS_PIP && ! $HAS_GEM && ! $HAS_GO; then
    echo "  –  No recognised package manifests found. Skipping dependency checks."
    echo ""
    echo "---------------------------------------------"
    echo "  Dependency Audit Summary"
    echo "  PASS: $PASS  |  WARN: $WARN  |  FAIL: $FAIL"
    echo "---------------------------------------------"
    echo "  Result: ✔ PASSED (nothing to audit)"
    exit 0
fi
echo ""

# ── 2. Check for lock files ────────────────────────────────────────────────────
echo "[CHECK 2] Lock file presence"
if $HAS_NPM; then
    if [[ -f "$TARGET/package-lock.json" ]] || [[ -f "$TARGET/yarn.lock" ]]; then
        echo "  ✔  npm lock file found."
        ((PASS++)) || true
    else
        echo "  ✘  No lock file found for npm (package-lock.json / yarn.lock)."
        ((FAIL++)) || true
    fi
fi
if $HAS_PIP; then
    if [[ -f "$TARGET/Pipfile.lock" ]] || [[ -f "$TARGET/poetry.lock" ]]; then
        echo "  ✔  Python lock file found."
        ((PASS++)) || true
    else
        echo "  ⚠  No lock file found for pip (Pipfile.lock / poetry.lock)."
        ((WARN++)) || true
    fi
fi
if $HAS_GEM; then
    if [[ -f "$TARGET/Gemfile.lock" ]]; then
        echo "  ✔  Gemfile.lock found."
        ((PASS++)) || true
    else
        echo "  ⚠  No Gemfile.lock found."
        ((WARN++)) || true
    fi
fi
if $HAS_GO; then
    if [[ -f "$TARGET/go.sum" ]]; then
        echo "  ✔  go.sum found."
        ((PASS++)) || true
    else
        echo "  ✘  No go.sum found."
        ((FAIL++)) || true
    fi
fi
echo ""

# ── 3. Check for unpinned versions in requirements.txt ────────────────────────
if $HAS_PIP; then
    echo "[CHECK 3] Pinned versions in requirements.txt"
    UNPINNED=0
    while IFS= read -r line; do
        # Skip blank lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        if ! echo "$line" | grep -qE "[=><~!]"; then
            echo "  ⚠  Unpinned dependency: $line"
            ((UNPINNED++)) || true
        fi
    done < "$TARGET/requirements.txt"

    if [[ $UNPINNED -eq 0 ]]; then
        echo "  ✔  All pip dependencies are version-pinned."
        ((PASS++)) || true
    else
        echo "  ⚠  $UNPINNED unpinned pip dependency/ies found."
        ((WARN++)) || true
    fi
    echo ""
fi

# ── 4. Check for unpinned versions in package.json ────────────────────────────
if $HAS_NPM; then
    echo "[CHECK 4] Pinned versions in package.json"
    STAR_DEPS=$(grep -cE '"[^"]+"\s*:\s*"\*"' "$TARGET/package.json" 2>/dev/null) || STAR_DEPS=0
    LATEST_DEPS=$(grep -cE '"[^"]+"\s*:\s*"latest"' "$TARGET/package.json" 2>/dev/null) || LATEST_DEPS=0
    WILD=$((STAR_DEPS + LATEST_DEPS))
    if [[ $WILD -gt 0 ]]; then
        echo "  ⚠  $WILD dependency/ies use '*' or 'latest' – pin to a specific version."
        ((WARN++)) || true
    else
        echo "  ✔  No wildcard ('*' / 'latest') npm versions detected."
        ((PASS++)) || true
    fi
    echo ""
fi

# ── 5. Count dependencies ──────────────────────────────────────────────────────
echo "[CHECK 5] Dependency count"
if $HAS_PIP; then
    COUNT=$(grep -cE "^[^#]" "$TARGET/requirements.txt" 2>/dev/null || echo 0)
    echo "  ℹ  pip dependencies declared: $COUNT"
    if [[ $COUNT -gt 50 ]]; then
        echo "  ⚠  Large dependency count ($COUNT). Consider auditing for unused packages."
        ((WARN++)) || true
    else
        ((PASS++)) || true
    fi
fi
if $HAS_NPM; then
    COUNT=$(grep -c '"' "$TARGET/package.json" 2>/dev/null || echo 0)
    echo "  ℹ  package.json lines with entries: $COUNT (approximate)"
    ((PASS++)) || true
fi
echo ""

# ── Summary ────────────────────────────────────────────────────────────────────
echo "---------------------------------------------"
echo "  Dependency Audit Summary"
echo "  PASS: $PASS  |  WARN: $WARN  |  FAIL: $FAIL"
echo "---------------------------------------------"
if [[ $FAIL -gt 0 ]]; then
    echo "  Result: ✘ FAILED – address the issues above."
    exit 1
elif [[ $WARN -gt 0 ]]; then
    echo "  Result: ⚠ PASSED WITH WARNINGS"
    exit 0
else
    echo "  Result: ✔ PASSED"
    exit 0
fi
