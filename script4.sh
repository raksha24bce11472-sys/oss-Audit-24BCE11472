#!/usr/bin/env bash
# script4.sh — Security Vulnerability Scan Script
# OSS Audit Project | Student ID: 24BCE11472
#
# Purpose: Perform basic security checks on the repository — scan for
#          hard-coded secrets, insecure patterns, and risky file permissions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/audit_output"
SECURITY_FILE="$OUTPUT_DIR/security.txt"

mkdir -p "$OUTPUT_DIR"

echo "[script4] Starting security vulnerability scan..."
echo ""

> "$SECURITY_FILE"
echo "Security Audit Report" >> "$SECURITY_FILE"
echo "=====================" >> "$SECURITY_FILE"
echo "Date: $(date)" >> "$SECURITY_FILE"
echo "" >> "$SECURITY_FILE"

ISSUES=0

flag_issue() {
    local msg="$1"
    echo "[script4] ISSUE: $msg"
    echo "ISSUE: $msg" >> "$SECURITY_FILE"
    ISSUES=$((ISSUES + 1))
}

# ----------------------------------------------------------------
# Check 1: Hard-coded secrets patterns
# ----------------------------------------------------------------
echo "[script4] Checking for hard-coded secrets..."
echo "--- Hard-coded Secrets Check ---" >> "$SECURITY_FILE"

SECRET_PATTERNS=(
    "password\s*=\s*['\"][^'\"]{4,}"
    "passwd\s*=\s*['\"][^'\"]{4,}"
    "secret\s*=\s*['\"][^'\"]{4,}"
    "api_key\s*=\s*['\"][^'\"]{4,}"
    "apikey\s*=\s*['\"][^'\"]{4,}"
    "access_token\s*=\s*['\"][^'\"]{4,}"
    "private_key\s*=\s*['\"][^'\"]{4,}"
)

for pattern in "${SECRET_PATTERNS[@]}"; do
    results=$(grep -rniE "$pattern" "$SCRIPT_DIR" \
        --exclude-dir=.git \
        --exclude-dir=audit_output \
        --exclude="security.txt" 2>/dev/null || true)
    if [ -n "$results" ]; then
        flag_issue "Possible hard-coded secret matching pattern '$pattern':"
        echo "$results" | head -10 >> "$SECURITY_FILE"
        echo "" >> "$SECURITY_FILE"
    fi
done

# ----------------------------------------------------------------
# Check 2: World-writable files
# ----------------------------------------------------------------
echo "[script4] Checking for world-writable files..."
echo "--- World-Writable Files Check ---" >> "$SECURITY_FILE"

writable=$(find "$SCRIPT_DIR" -not -path "*/.git/*" \
    -not -path "*/audit_output/*" \
    -perm -o+w -type f 2>/dev/null || true)

if [ -n "$writable" ]; then
    flag_issue "World-writable files found:"
    echo "$writable" >> "$SECURITY_FILE"
    echo "" >> "$SECURITY_FILE"
else
    echo "[script4]   OK: No world-writable files."
    echo "OK: No world-writable files." >> "$SECURITY_FILE"
fi

# ----------------------------------------------------------------
# Check 3: Files with SUID/SGID bits
# ----------------------------------------------------------------
echo "[script4] Checking for SUID/SGID files..."
echo "--- SUID/SGID Files Check ---" >> "$SECURITY_FILE"

suid_files=$(find "$SCRIPT_DIR" -not -path "*/.git/*" \
    \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null || true)

if [ -n "$suid_files" ]; then
    flag_issue "SUID/SGID files found:"
    echo "$suid_files" >> "$SECURITY_FILE"
    echo "" >> "$SECURITY_FILE"
else
    echo "[script4]   OK: No SUID/SGID files."
    echo "OK: No SUID/SGID files." >> "$SECURITY_FILE"
fi

# ----------------------------------------------------------------
# Check 4: eval usage in shell scripts
# ----------------------------------------------------------------
echo "[script4] Checking for unsafe 'eval' usage in shell scripts..."
echo "--- Unsafe eval Usage Check ---" >> "$SECURITY_FILE"

eval_usage=$(grep -rn '\beval\b' "$SCRIPT_DIR" \
    --include="*.sh" \
    --exclude-dir=.git \
    --exclude-dir=audit_output 2>/dev/null || true)

if [ -n "$eval_usage" ]; then
    flag_issue "Potentially unsafe 'eval' usage found:"
    echo "$eval_usage" >> "$SECURITY_FILE"
    echo "" >> "$SECURITY_FILE"
else
    echo "[script4]   OK: No eval usage in shell scripts."
    echo "OK: No eval usage in shell scripts." >> "$SECURITY_FILE"
fi

# ----------------------------------------------------------------
# Summary
# ----------------------------------------------------------------
echo "" >> "$SECURITY_FILE"
echo "=======================" >> "$SECURITY_FILE"
echo "Total Issues Found: $ISSUES" >> "$SECURITY_FILE"
echo "=======================" >> "$SECURITY_FILE"

echo ""
if [ "$ISSUES" -gt 0 ]; then
    echo "[script4] WARNING: $ISSUES security issue(s) found. See: $SECURITY_FILE"
else
    echo "[script4] No security issues found."
fi

echo "[script4] Security scan results saved to: $SECURITY_FILE"
echo "[script4] Security vulnerability scan complete."
