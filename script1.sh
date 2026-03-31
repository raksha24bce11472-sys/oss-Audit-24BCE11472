#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 24BCE11472 – OSS NGMC Capstone Project
# script1.sh – License Audit
#
# Scans source files and package manifests for license identifiers.
# Flags files that are missing a license header or carry a non-permissive license.
#
# Usage: ./script1.sh [path-to-project]

set -euo pipefail

TARGET="${1:-.}"

echo "============================================="
echo "  OSS Audit – Script 1: License Audit"
echo "  Target: $TARGET"
echo "============================================="
echo ""

PASS=0
WARN=0
FAIL=0

# ── 1. Check for a top-level LICENSE file ──────────────────────────────────────
echo "[CHECK 1] Top-level LICENSE file"
if find "$TARGET" -maxdepth 1 -iname "LICENSE*" | grep -q .; then
    echo "  ✔  LICENSE file found."
    ((PASS++)) || true
else
    echo "  ✘  No LICENSE file found at the project root."
    ((FAIL++)) || true
fi
echo ""

# ── 2. Detect license type ─────────────────────────────────────────────────────
echo "[CHECK 2] License type"
LICENSE_FILE=$(find "$TARGET" -maxdepth 1 -iname "LICENSE*" | head -n 1 || true)
if [[ -n "$LICENSE_FILE" ]]; then
    if grep -qiE "MIT License|Permission is hereby granted" "$LICENSE_FILE" 2>/dev/null; then
        echo "  ✔  MIT License detected (permissive)."
        ((PASS++)) || true
    elif grep -qiE "Apache License" "$LICENSE_FILE" 2>/dev/null; then
        echo "  ✔  Apache 2.0 License detected (permissive)."
        ((PASS++)) || true
    elif grep -qiE "GNU General Public License|GPL" "$LICENSE_FILE" 2>/dev/null; then
        echo "  ⚠  GPL License detected (copyleft – verify compatibility)."
        ((WARN++)) || true
    elif grep -qiE "GNU Lesser General Public License|LGPL" "$LICENSE_FILE" 2>/dev/null; then
        echo "  ⚠  LGPL License detected (weak copyleft – verify compatibility)."
        ((WARN++)) || true
    elif grep -qiE "BSD" "$LICENSE_FILE" 2>/dev/null; then
        echo "  ✔  BSD License detected (permissive)."
        ((PASS++)) || true
    else
        echo "  ⚠  License type could not be determined automatically. Review manually."
        ((WARN++)) || true
    fi
else
    echo "  –  Skipped (no LICENSE file found)."
fi
echo ""

# ── 3. Check source files for license headers ──────────────────────────────────
echo "[CHECK 3] License headers in source files"
TOTAL_SRC=0
MISSING_HEADER=0
while IFS= read -r -d '' file; do
    ((TOTAL_SRC++)) || true
    if ! head -20 "$file" | grep -qiE "license|copyright|spdx"; then
        echo "  ⚠  Missing header: $file"
        ((MISSING_HEADER++)) || true
    fi
done < <(find "$TARGET" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \
         -o -name "*.ts" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" \) \
         -not -path "*/.git/*" -print0)

if [[ $TOTAL_SRC -eq 0 ]]; then
    echo "  –  No source files found to check."
elif [[ $MISSING_HEADER -eq 0 ]]; then
    echo "  ✔  All $TOTAL_SRC source file(s) contain a license header."
    ((PASS++)) || true
else
    echo "  ⚠  $MISSING_HEADER / $TOTAL_SRC source file(s) are missing a license header."
    ((WARN++)) || true
fi
echo ""

# ── 4. Check package manifests for dependency licenses ─────────────────────────
echo "[CHECK 4] Dependency license declarations"
MANIFEST_FOUND=false
for manifest in package.json requirements.txt Gemfile pom.xml go.mod; do
    if [[ -f "$TARGET/$manifest" ]]; then
        echo "  ✔  Found manifest: $manifest"
        MANIFEST_FOUND=true
        ((PASS++)) || true
    fi
done
if [[ "$MANIFEST_FOUND" == false ]]; then
    echo "  –  No recognised package manifests found."
fi
echo ""

# ── Summary ────────────────────────────────────────────────────────────────────
echo "---------------------------------------------"
echo "  License Audit Summary"
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
