#!/usr/bin/env bash
# script5.sh — Audit Report Generation Script
# OSS Audit Project | Student ID: 24BCE11472
#
# Purpose: Consolidate all individual audit results into a single
#          comprehensive audit report.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/audit_output"
REPORT_FILE="$OUTPUT_DIR/audit_report.txt"

mkdir -p "$OUTPUT_DIR"

echo "[script5] Generating consolidated audit report..."
echo ""

TIMESTAMP=$(date)
HOSTNAME=$(hostname)

> "$REPORT_FILE"

cat >> "$REPORT_FILE" << EOF
================================================================
          OSS AUDIT — CONSOLIDATED REPORT
          Student ID: 24BCE11472
================================================================
Generated : $TIMESTAMP
Host      : $HOSTNAME
Directory : $SCRIPT_DIR
----------------------------------------------------------------

EOF

# ----------------------------------------------------------------
# Section 1: Environment
# ----------------------------------------------------------------
ENV_FILE="$OUTPUT_DIR/environment.txt"
echo "--- Section 1: Environment ---" >> "$REPORT_FILE"
if [ -f "$ENV_FILE" ]; then
    cat "$ENV_FILE" >> "$REPORT_FILE"
else
    echo "(environment.txt not found — run script1.sh first)" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# ----------------------------------------------------------------
# Section 2: Dependencies
# ----------------------------------------------------------------
DEPS_FILE="$OUTPUT_DIR/dependencies.txt"
echo "--- Section 2: Dependencies ---" >> "$REPORT_FILE"
if [ -f "$DEPS_FILE" ]; then
    cat "$DEPS_FILE" >> "$REPORT_FILE"
else
    echo "(dependencies.txt not found — run script2.sh first)" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# ----------------------------------------------------------------
# Section 3: Licenses
# ----------------------------------------------------------------
LICENSE_FILE="$OUTPUT_DIR/licenses.txt"
echo "--- Section 3: Licenses ---" >> "$REPORT_FILE"
if [ -f "$LICENSE_FILE" ]; then
    cat "$LICENSE_FILE" >> "$REPORT_FILE"
else
    echo "(licenses.txt not found — run script3.sh first)" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# ----------------------------------------------------------------
# Section 4: Security
# ----------------------------------------------------------------
SECURITY_FILE="$OUTPUT_DIR/security.txt"
echo "--- Section 4: Security ---" >> "$REPORT_FILE"
if [ -f "$SECURITY_FILE" ]; then
    cat "$SECURITY_FILE" >> "$REPORT_FILE"
else
    echo "(security.txt not found — run script4.sh first)" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# ----------------------------------------------------------------
# Summary
# ----------------------------------------------------------------
cat >> "$REPORT_FILE" << 'EOF'
================================================================
                          SUMMARY
================================================================
EOF

SECURITY_ISSUES=0
if [ -f "$SECURITY_FILE" ]; then
    SECURITY_ISSUES=$(grep -c "^ISSUE:" "$SECURITY_FILE" 2>/dev/null || true)
fi

HAS_LICENSE="No"
if [ -f "$LICENSE_FILE" ] && ! grep -q "WARNING: No license file found." "$LICENSE_FILE" 2>/dev/null; then
    HAS_LICENSE="Yes"
fi

HAS_DEPS="No"
if [ -f "$DEPS_FILE" ] && ! grep -q "No dependency manifests found." "$DEPS_FILE" 2>/dev/null; then
    HAS_DEPS="Yes"
fi

cat >> "$REPORT_FILE" << EOF
License File Found  : $HAS_LICENSE
Dependency Manifests: $HAS_DEPS
Security Issues     : $SECURITY_ISSUES

Audit Status        : $([ "$SECURITY_ISSUES" -eq 0 ] && echo "PASSED" || echo "REVIEW REQUIRED")
================================================================
EOF

echo "[script5] Consolidated audit report saved to: $REPORT_FILE"
echo ""
echo "[script5] ================================================================"
echo "[script5]   License File Found  : $HAS_LICENSE"
echo "[script5]   Dependency Manifests: $HAS_DEPS"
echo "[script5]   Security Issues     : $SECURITY_ISSUES"
echo "[script5] ================================================================"
echo "[script5] Report generation complete."
