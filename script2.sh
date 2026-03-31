#!/usr/bin/env bash
# script2.sh — Dependency Audit Script
# OSS Audit Project | Student ID: 24BCE11472
#
# Purpose: Detect and list project dependencies from common package
#          manifest files (package.json, requirements.txt, pom.xml, etc.)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/audit_output"
DEPS_FILE="$OUTPUT_DIR/dependencies.txt"

mkdir -p "$OUTPUT_DIR"

echo "[script2] Starting dependency audit..."
echo ""

> "$DEPS_FILE"
echo "Dependency Audit Report" >> "$DEPS_FILE"
echo "=======================" >> "$DEPS_FILE"
echo "Date: $(date)" >> "$DEPS_FILE"
echo "" >> "$DEPS_FILE"

FOUND=0

check_file() {
    local file="$1"
    local label="$2"
    if [ -f "$file" ]; then
        echo "[script2] Found: $file ($label)"
        echo "[$label] $file" >> "$DEPS_FILE"
        echo "---" >> "$DEPS_FILE"
        cat "$file" >> "$DEPS_FILE"
        echo "" >> "$DEPS_FILE"
        FOUND=1
    fi
}

# Node.js
check_file "$SCRIPT_DIR/package.json"       "Node.js (npm)"
check_file "$SCRIPT_DIR/package-lock.json"  "Node.js (npm lockfile)"
check_file "$SCRIPT_DIR/yarn.lock"          "Node.js (yarn lockfile)"

# Python
check_file "$SCRIPT_DIR/requirements.txt"   "Python (pip)"
check_file "$SCRIPT_DIR/Pipfile"            "Python (pipenv)"
check_file "$SCRIPT_DIR/pyproject.toml"     "Python (pyproject)"

# Java
check_file "$SCRIPT_DIR/pom.xml"            "Java (Maven)"
check_file "$SCRIPT_DIR/build.gradle"       "Java (Gradle)"

# Ruby
check_file "$SCRIPT_DIR/Gemfile"            "Ruby (Bundler)"
check_file "$SCRIPT_DIR/Gemfile.lock"       "Ruby (Bundler lockfile)"

# Go
check_file "$SCRIPT_DIR/go.mod"             "Go (modules)"
check_file "$SCRIPT_DIR/go.sum"             "Go (modules checksum)"

# Rust
check_file "$SCRIPT_DIR/Cargo.toml"         "Rust (Cargo)"
check_file "$SCRIPT_DIR/Cargo.lock"         "Rust (Cargo lockfile)"

if [ "$FOUND" -eq 0 ]; then
    echo "[script2] No known dependency manifest files found in project root."
    echo "No dependency manifests found." >> "$DEPS_FILE"
else
    echo "[script2] Dependency information saved to: $DEPS_FILE"
fi

echo ""
echo "[script2] Dependency audit complete."
