#!/usr/bin/env bash
# script1.sh — Environment Setup Script
# OSS Audit Project | Student ID: 24BCE11472
#
# Purpose: Verify that all required tools and environment variables
#          are present before running the audit pipeline.

set -euo pipefail

echo "[script1] Starting environment setup..."

REQUIRED_TOOLS=("curl" "wget" "git" "awk" "sed" "grep" "find")
MISSING_TOOLS=()

echo "[script1] Checking required tools..."
for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        echo "[script1]   OK: $tool ($(command -v "$tool"))"
    else
        echo "[script1]   MISSING: $tool"
        MISSING_TOOLS+=("$tool")
    fi
done

if [ "${#MISSING_TOOLS[@]}" -gt 0 ]; then
    echo "[script1] ERROR: Missing tools: ${MISSING_TOOLS[*]}"
    echo "[script1] Please install the missing tools and re-run."
    exit 1
fi

echo "[script1] All required tools are present."
echo ""

# Create output directory for audit results
OUTPUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/audit_output"
mkdir -p "$OUTPUT_DIR"
echo "[script1] Audit output directory: $OUTPUT_DIR"

# Record environment info
ENV_FILE="$OUTPUT_DIR/environment.txt"
{
    echo "Audit Environment Info"
    echo "======================"
    echo "Date       : $(date)"
    echo "Hostname   : $(hostname)"
    echo "OS         : $(uname -a)"
    echo "Bash       : $BASH_VERSION"
    echo "User       : $(whoami)"
    echo "Working Dir: $(pwd)"
    echo ""
    echo "Available Tools:"
    for tool in "${REQUIRED_TOOLS[@]}"; do
        echo "  $tool -> $(command -v "$tool")"
    done
} > "$ENV_FILE"

echo "[script1] Environment info saved to: $ENV_FILE"
echo "[script1] Environment setup complete."
