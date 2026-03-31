#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 24BCE11472 – OSS NGMC Capstone Project
# script4.sh – Documentation Audit
#
# Checks for the presence of key documentation files (README, LICENSE,
# CONTRIBUTING, CHANGELOG) and validates inline comment density in source files.
#
# Usage: ./script4.sh [path-to-project]

set -euo pipefail

TARGET="${1:-.}"

echo "============================================="
echo "  OSS Audit – Script 4: Documentation Audit"
echo "  Target: $TARGET"
echo "============================================="
echo ""

PASS=0
WARN=0
FAIL=0

# ── 1. Required top-level files ───────────────────────────────────────────────
echo "[CHECK 1] Required documentation files"
declare -A DOC_FILES=(
    ["README"]="README.md README.rst README.txt README"
    ["LICENSE"]="LICENSE LICENSE.md LICENSE.txt COPYING"
    ["CONTRIBUTING"]="CONTRIBUTING.md CONTRIBUTING.rst CONTRIBUTING.txt"
    ["CHANGELOG"]="CHANGELOG.md CHANGELOG.rst CHANGELOG.txt HISTORY.md"
)

for doc in README LICENSE CONTRIBUTING CHANGELOG; do
    FOUND=false
    for name in ${DOC_FILES[$doc]}; do
        if [[ -f "$TARGET/$name" ]]; then
            echo "  ✔  $doc found: $name"
            FOUND=true
            ((PASS++)) || true
            break
        fi
    done
    if [[ "$FOUND" == false ]]; then
        if [[ "$doc" == "README" || "$doc" == "LICENSE" ]]; then
            echo "  ✘  $doc is MISSING (required)."
            ((FAIL++)) || true
        else
            echo "  ⚠  $doc is missing (recommended)."
            ((WARN++)) || true
        fi
    fi
done
echo ""

# ── 2. README quality checks ──────────────────────────────────────────────────
echo "[CHECK 2] README quality"
README_FILE=$(find "$TARGET" -maxdepth 1 -iname "README*" | head -n 1 || true)
if [[ -n "$README_FILE" ]]; then
    README_LINES=$(wc -l < "$README_FILE")
    echo "  ℹ  README line count: $README_LINES"

    if [[ $README_LINES -lt 10 ]]; then
        echo "  ✘  README is very short (< 10 lines). Expand project documentation."
        ((FAIL++)) || true
    elif [[ $README_LINES -lt 30 ]]; then
        echo "  ⚠  README is brief (< 30 lines). Consider adding more documentation."
        ((WARN++)) || true
    else
        echo "  ✔  README has adequate length."
        ((PASS++)) || true
    fi

    # Check for key sections
    for section in "install|setup|getting started" "usage|how to use|running" "license"; do
        if grep -qiE "$section" "$README_FILE" 2>/dev/null; then
            echo "  ✔  README contains '$(echo "$section" | tr '|' '/')' section."
            ((PASS++)) || true
        else
            echo "  ⚠  README may be missing a '$(echo "$section" | tr '|' '/')' section."
            ((WARN++)) || true
        fi
    done
else
    echo "  –  README not found, skipping quality checks."
fi
echo ""

# ── 3. Inline comment density ─────────────────────────────────────────────────
echo "[CHECK 3] Inline comment density in source files"
TOTAL_LINES=0
COMMENT_LINES=0

while IFS= read -r -d '' file; do
    EXT="${file##*.}"
    case "$EXT" in
        sh|bash)   COMMENT_PATTERN='^[[:space:]]*#' ;;
        py)        COMMENT_PATTERN='^[[:space:]]*#' ;;
        js|ts)     COMMENT_PATTERN='^[[:space:]]*//' ;;
        java|c|cpp) COMMENT_PATTERN='^[[:space:]]*//' ;;
        *)         continue ;;
    esac
    FILE_TOTAL=$(wc -l < "$file")
    FILE_COMMENTS=$(grep -cE "$COMMENT_PATTERN" "$file" 2>/dev/null || echo 0)
    TOTAL_LINES=$((TOTAL_LINES + FILE_TOTAL))
    COMMENT_LINES=$((COMMENT_LINES + FILE_COMMENTS))
done < <(find "$TARGET" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \
         -o -name "*.ts" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" \) \
         -not -path "*/.git/*" -not -path "*/node_modules/*" -print0)

if [[ $TOTAL_LINES -gt 0 ]]; then
    RATIO=$(awk "BEGIN {printf \"%.1f\", ($COMMENT_LINES / $TOTAL_LINES) * 100}")
    echo "  ℹ  Comment density: $COMMENT_LINES / $TOTAL_LINES lines = ${RATIO}%"
    if awk "BEGIN {exit ($COMMENT_LINES / $TOTAL_LINES) >= 0.10 ? 0 : 1}"; then
        echo "  ✔  Comment density is at least 10% – adequate."
        ((PASS++)) || true
    else
        echo "  ⚠  Comment density is below 10% – consider adding inline documentation."
        ((WARN++)) || true
    fi
else
    echo "  –  No source files found to measure."
fi
echo ""

# ── 4. Check for a code-of-conduct file ───────────────────────────────────────
echo "[CHECK 4] Code of Conduct"
if find "$TARGET" -maxdepth 2 -iname "CODE_OF_CONDUCT*" | grep -q .; then
    echo "  ✔  CODE_OF_CONDUCT file found."
    ((PASS++)) || true
else
    echo "  ⚠  No CODE_OF_CONDUCT file found (recommended for community projects)."
    ((WARN++)) || true
fi
echo ""

# ── Summary ────────────────────────────────────────────────────────────────────
echo "---------------------------------------------"
echo "  Documentation Audit Summary"
echo "  PASS: $PASS  |  WARN: $WARN  |  FAIL: $FAIL"
echo "---------------------------------------------"
if [[ $FAIL -gt 0 ]]; then
    echo "  Result: ✘ FAILED – critical documentation is missing."
    exit 1
elif [[ $WARN -gt 0 ]]; then
    echo "  Result: ⚠ PASSED WITH WARNINGS – some documentation improvements recommended."
    exit 0
else
    echo "  Result: ✔ PASSED"
    exit 0
fi
