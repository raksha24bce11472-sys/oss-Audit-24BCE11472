#!/usr/bin/env bash
# script3.sh — License Checker Script
# OSS Audit Project | Student ID: 24BCE11472
#
# Purpose: Scan the repository for license files and identify the
#          type of open-source license(s) used in the project.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/audit_output"
LICENSE_FILE="$OUTPUT_DIR/licenses.txt"

mkdir -p "$OUTPUT_DIR"

echo "[script3] Starting license check..."
echo ""

> "$LICENSE_FILE"
echo "License Audit Report" >> "$LICENSE_FILE"
echo "====================" >> "$LICENSE_FILE"
echo "Date: $(date)" >> "$LICENSE_FILE"
echo "" >> "$LICENSE_FILE"

FOUND=0

# Common license file names
LICENSE_NAMES=("LICENSE" "LICENSE.txt" "LICENSE.md" "LICENCE" "LICENCE.txt"
               "COPYING" "COPYING.txt" "NOTICE" "NOTICE.txt")

echo "[script3] Scanning for license files..."
for name in "${LICENSE_NAMES[@]}"; do
    filepath="$SCRIPT_DIR/$name"
    if [ -f "$filepath" ]; then
        echo "[script3]   Found: $name"
        echo "=== $name ===" >> "$LICENSE_FILE"
        cat "$filepath" >> "$LICENSE_FILE"
        echo "" >> "$LICENSE_FILE"
        FOUND=1
    fi
done

# Detect license type by keyword matching
detect_license_type() {
    local file="$1"
    local content
    content=$(cat "$file" 2>/dev/null || true)

    if echo "$content" | grep -qi "MIT License"; then
        echo "MIT"
    elif echo "$content" | grep -qi "Apache License"; then
        echo "Apache-2.0"
    elif echo "$content" | grep -qi "GNU GENERAL PUBLIC LICENSE"; then
        echo "GPL"
    elif echo "$content" | grep -qi "GNU LESSER GENERAL PUBLIC LICENSE"; then
        echo "LGPL"
    elif echo "$content" | grep -qi "BSD"; then
        echo "BSD"
    elif echo "$content" | grep -qi "Mozilla Public License"; then
        echo "MPL-2.0"
    elif echo "$content" | grep -qi "ISC License"; then
        echo "ISC"
    else
        echo "Unknown/Custom"
    fi
}

echo "" >> "$LICENSE_FILE"
echo "Detected License Types:" >> "$LICENSE_FILE"
echo "-----------------------" >> "$LICENSE_FILE"

for name in "${LICENSE_NAMES[@]}"; do
    filepath="$SCRIPT_DIR/$name"
    if [ -f "$filepath" ]; then
        ltype=$(detect_license_type "$filepath")
        echo "[script3]   $name -> $ltype"
        echo "$name: $ltype" >> "$LICENSE_FILE"
    fi
done

if [ "$FOUND" -eq 0 ]; then
    echo "[script3] WARNING: No license file found in project root."
    echo "WARNING: No license file found." >> "$LICENSE_FILE"
fi

echo ""
echo "[script3] License check results saved to: $LICENSE_FILE"
echo "[script3] License check complete."
