#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 24BCE11472 – OSS NGMC Capstone Project
# script5.sh – Code Quality Audit
#
# Reports code quality metrics: file size, function complexity, test coverage
# ratio, use of shellcheck/linting, and duplicate code indicators.
#
# Usage: ./script5.sh [path-to-project]

set -euo pipefail

TARGET="${1:-.}"

echo "============================================="
echo "  OSS Audit – Script 5: Code Quality Audit"
echo "  Target: $TARGET"
echo "============================================="
echo ""

PASS=0
WARN=0
FAIL=0

# ── 1. Detect oversized source files ──────────────────────────────────────────
echo "[CHECK 1] Oversized source files (> 500 lines)"
LARGE_FILES=0
while IFS= read -r -d '' file; do
    LINES=$(wc -l < "$file")
    if [[ $LINES -gt 500 ]]; then
        echo "  ⚠  $file ($LINES lines)"
        ((LARGE_FILES++)) || true
    fi
done < <(find "$TARGET" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \
         -o -name "*.ts" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" \) \
         -not -path "*/.git/*" -not -path "*/node_modules/*" -print0)

if [[ $LARGE_FILES -eq 0 ]]; then
    echo "  ✔  No oversized source files found."
    ((PASS++)) || true
else
    echo "  ⚠  $LARGE_FILES oversized file(s) found. Consider refactoring."
    ((WARN++)) || true
fi
echo ""

# ── 2. Long functions / methods ───────────────────────────────────────────────
echo "[CHECK 2] Functions longer than 50 lines (shell scripts)"
LONG_FUNCS=0
while IFS= read -r -d '' file; do
    # Count lines between function definitions
    awk '
    /^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)/ { fn=$0; start=NR }
    start && NR - start > 50 && /^}/ {
        print FILENAME ":" start ": function is " NR-start " lines long"
        start=0
    }
    /^}/ { start=0 }
    ' "$file" 2>/dev/null | while IFS= read -r line; do
        echo "  ⚠  $line"
        ((LONG_FUNCS++)) || true
    done
done < <(find "$TARGET" -type f -name "*.sh" \
         -not -path "*/.git/*" -print0)

if [[ $LONG_FUNCS -eq 0 ]]; then
    echo "  ✔  No excessively long shell functions detected."
    ((PASS++)) || true
fi
echo ""

# ── 3. Test file ratio ─────────────────────────────────────────────────────────
echo "[CHECK 3] Test file presence"
SRC_COUNT=$(find "$TARGET" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \
            -o -name "*.ts" -o -name "*.java" \) \
            -not -path "*/.git/*" -not -path "*/node_modules/*" \
            -not -name "*test*" -not -name "*spec*" | wc -l)
TEST_COUNT=$(find "$TARGET" -type f \( -name "*test*" -o -name "*spec*" \) \
             -not -path "*/.git/*" -not -path "*/node_modules/*" | wc -l)

echo "  ℹ  Source files : $SRC_COUNT"
echo "  ℹ  Test files   : $TEST_COUNT"

if [[ $SRC_COUNT -eq 0 ]]; then
    echo "  –  No source files to evaluate."
elif [[ $TEST_COUNT -eq 0 ]]; then
    echo "  ⚠  No test files found. Consider adding automated tests."
    ((WARN++)) || true
else
    RATIO=$(awk "BEGIN {printf \"%.1f\", ($TEST_COUNT / $SRC_COUNT) * 100}")
    echo "  ℹ  Test-to-source ratio: ${RATIO}%"
    if awk "BEGIN {exit ($TEST_COUNT / $SRC_COUNT) >= 0.2 ? 0 : 1}" 2>/dev/null; then
        echo "  ✔  Test coverage ratio is acceptable."
        ((PASS++)) || true
    else
        echo "  ⚠  Low test-to-source ratio. Add more tests."
        ((WARN++)) || true
    fi
fi
echo ""

# ── 4. Shellcheck availability ────────────────────────────────────────────────
echo "[CHECK 4] Shellcheck linting (shell scripts)"
SHELL_SCRIPTS=$(find "$TARGET" -type f -name "*.sh" \
                -not -path "*/.git/*" | wc -l)
if [[ $SHELL_SCRIPTS -eq 0 ]]; then
    echo "  –  No shell scripts found."
else
    if command -v shellcheck &>/dev/null; then
        SC_ISSUES=0
        while IFS= read -r -d '' script; do
            if ! shellcheck "$script" 2>/dev/null; then
                ((SC_ISSUES++)) || true
            fi
        done < <(find "$TARGET" -type f -name "*.sh" \
                 -not -path "*/.git/*" -print0)
        if [[ $SC_ISSUES -eq 0 ]]; then
            echo "  ✔  shellcheck passed on all $SHELL_SCRIPTS script(s)."
            ((PASS++)) || true
        else
            echo "  ⚠  shellcheck reported issues in $SC_ISSUES script(s)."
            ((WARN++)) || true
        fi
    else
        echo "  ⚠  shellcheck is not installed. Install it for detailed shell linting."
        ((WARN++)) || true
    fi
fi
echo ""

# ── 5. Trailing whitespace and mixed line endings ─────────────────────────────
echo "[CHECK 5] Trailing whitespace"
TW_COUNT=0
while IFS= read -r -d '' file; do
    COUNT=$(grep -cP "[ \t]+$" "$file" 2>/dev/null) || COUNT=0
    if [[ "$COUNT" -gt 0 ]]; then
        echo "  ⚠  $file has $COUNT line(s) with trailing whitespace."
        ((TW_COUNT++)) || true
    fi
done < <(find "$TARGET" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \
         -o -name "*.ts" \) -not -path "*/.git/*" -print0)

if [[ $TW_COUNT -eq 0 ]]; then
    echo "  ✔  No trailing whitespace found."
    ((PASS++)) || true
else
    echo "  ⚠  $TW_COUNT file(s) contain trailing whitespace."
    ((WARN++)) || true
fi
echo ""

# ── 6. TODO / FIXME count ─────────────────────────────────────────────────────
echo "[CHECK 6] Outstanding TODO / FIXME comments"
TODO_COUNT=$(grep -rniE "(TODO|FIXME|HACK|XXX)" "$TARGET" \
             --include="*.sh" --include="*.py" --include="*.js" \
             --include="*.ts" --include="*.java" \
             --exclude-dir=".git" --exclude-dir="node_modules" 2>/dev/null | wc -l || echo 0)
echo "  ℹ  Outstanding TODO/FIXME comments: $TODO_COUNT"
if [[ $TODO_COUNT -gt 20 ]]; then
    echo "  ⚠  High number of unresolved TODOs. Review and address before release."
    ((WARN++)) || true
else
    ((PASS++)) || true
fi
echo ""

# ── Summary ────────────────────────────────────────────────────────────────────
echo "---------------------------------------------"
echo "  Code Quality Audit Summary"
echo "  PASS: $PASS  |  WARN: $WARN  |  FAIL: $FAIL"
echo "---------------------------------------------"
if [[ $FAIL -gt 0 ]]; then
    echo "  Result: ✘ FAILED – critical quality issues found."
    exit 1
elif [[ $WARN -gt 0 ]]; then
    echo "  Result: ⚠ PASSED WITH WARNINGS – review flagged items."
    exit 0
else
    echo "  Result: ✔ PASSED"
    exit 0
fi
