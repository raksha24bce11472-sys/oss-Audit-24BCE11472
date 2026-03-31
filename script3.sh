#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 24BCE11472 – OSS NGMC Capstone Project
# script3.sh – Security Audit
#
# Searches for hard-coded secrets (passwords, API keys, tokens) and other
# common insecure patterns in source files.
#
# Usage: ./script3.sh [path-to-project]

set -euo pipefail

TARGET="${1:-.}"

echo "============================================="
echo "  OSS Audit – Script 3: Security Audit"
echo "  Target: $TARGET"
echo "============================================="
echo ""

PASS=0
WARN=0
FAIL=0

# ── Helper: search for a pattern and report results ───────────────────────────
check_pattern() {
    local description="$1"
    local pattern="$2"
    local severity="${3:-WARN}"   # WARN or FAIL

    echo "  Checking: $description"
    local results
    results=$(grep -rniE "$pattern" "$TARGET" \
              --include="*.sh" --include="*.py" --include="*.js" \
              --include="*.ts" --include="*.java" --include="*.env" \
              --include="*.config" --include="*.yml" --include="*.yaml" \
              --include="*.json" --include="*.xml" \
              --exclude-dir=".git" --exclude-dir="node_modules" \
              --exclude-dir="vendor" 2>/dev/null || true)

    if [[ -n "$results" ]]; then
        echo "$results" | while IFS= read -r line; do
            echo "    ⚠  $line"
        done
        if [[ "$severity" == "FAIL" ]]; then
            ((FAIL++)) || true
        else
            ((WARN++)) || true
        fi
    else
        echo "    ✔  None found."
        ((PASS++)) || true
    fi
    echo ""
}

# ── 1. Hard-coded passwords ────────────────────────────────────────────────────
echo "[CHECK 1] Hard-coded passwords"
check_pattern "password assignments" \
    '(password|passwd|pwd)\s*=\s*["'"'"'][^"'"'"']{3,}["'"'"']' "FAIL"

# ── 2. Hard-coded API keys / tokens ───────────────────────────────────────────
echo "[CHECK 2] Hard-coded API keys / tokens"
check_pattern "api_key / token assignments" \
    '(api_?key|api_?token|auth_?token|access_?token|secret_?key)\s*=\s*["'"'"'][^"'"'"']{8,}["'"'"']' "FAIL"

# ── 3. Private key / certificate material ─────────────────────────────────────
echo "[CHECK 3] Private key markers"
check_pattern "PEM private key headers" \
    "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----" "FAIL"

# ── 4. AWS credential patterns ────────────────────────────────────────────────
echo "[CHECK 4] AWS credentials"
check_pattern "AWS access key IDs" \
    "AKIA[0-9A-Z]{16}" "FAIL"

# ── 5. eval() usage in shell / JavaScript ─────────────────────────────────────
echo "[CHECK 5] Dangerous eval() usage"
check_pattern "eval() calls" \
    '\beval\s*\(' "WARN"

# ── 6. Disable certificate verification ───────────────────────────────────────
echo "[CHECK 6] Disabled TLS/SSL verification"
check_pattern "SSL verification disabled" \
    "(verify\s*=\s*False|InsecureRequestWarning|curl\s+(-k|--insecure)|ssl_verify\s*=\s*false)" "WARN"

# ── 7. exec() with variable input ─────────────────────────────────────────────
echo "[CHECK 7] exec() with user-controlled input"
check_pattern "exec() calls" \
    '\bexec\s*\(' "WARN"

# ── 8. TODO / FIXME security notes ────────────────────────────────────────────
echo "[CHECK 8] Security-related TODO / FIXME comments"
check_pattern "security TODOs" \
    "(TODO|FIXME|HACK|XXX).*?(security|auth|password|token|cred)" "WARN"

# ── Summary ────────────────────────────────────────────────────────────────────
echo "---------------------------------------------"
echo "  Security Audit Summary"
echo "  PASS: $PASS  |  WARN: $WARN  |  FAIL: $FAIL"
echo "---------------------------------------------"
if [[ $FAIL -gt 0 ]]; then
    echo "  Result: ✘ FAILED – critical security issues found. Fix before releasing."
    exit 1
elif [[ $WARN -gt 0 ]]; then
    echo "  Result: ⚠ PASSED WITH WARNINGS – review flagged patterns."
    exit 0
else
    echo "  Result: ✔ PASSED – no obvious security issues detected."
    exit 0
fi
