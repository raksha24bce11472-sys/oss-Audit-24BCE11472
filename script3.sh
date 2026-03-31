#!/bin/bash
# Script 3: Disk and Permission Auditor
# This script audits important Ubuntu directories
# and checks Git-related files used on Linux systems.

# Important Ubuntu directories
DIRS=("/etc" "/var/log" "/home" "/usr/bin" "/tmp")

echo "Directory Audit Report"
echo "----------------------"

# Loop through each directory
for DIR in "${DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        # Get permissions, owner, and group
        PERMS=$(ls -ld "$DIR" | awk '{print $1, $3, $4}')

        # Get total size of the directory
        SIZE=$(du -sh "$DIR" 2>/dev/null | cut -f1)

        # Get filesystem usage percentage
        FSUSE=$(df -h "$DIR" | awk 'NR==2 {print $5}')

        echo "$DIR => Permissions: $PERMS | Size: $SIZE | Filesystem Used: $FSUSE"
    else
        echo "$DIR does not exist on this system"
    fi
done

echo ""
echo "Git Configuration Audit"
echo "-----------------------"

# Git-related paths on Ubuntu/Linux
GIT_BINARY="/usr/bin/git"
GIT_SYSTEM_CONFIG="/etc/gitconfig"
GIT_GLOBAL_CONFIG="$HOME/.gitconfig"
GIT_XDG_CONFIG="$HOME/.config/git/config"

# Check Git binary
if [ -f "$GIT_BINARY" ]; then
    echo "Git binary found: $GIT_BINARY"
    ls -l "$GIT_BINARY"
else
    echo "Git binary not found at $GIT_BINARY"
fi

echo ""

# Check system Git config
if [ -f "$GIT_SYSTEM_CONFIG" ]; then
    echo "System Git config exists: $GIT_SYSTEM_CONFIG"
    ls -l "$GIT_SYSTEM_CONFIG"
else
    echo "System Git config does not exist: $GIT_SYSTEM_CONFIG"
fi

# Check global Git config
if [ -f "$GIT_GLOBAL_CONFIG" ]; then
    echo "Global Git config exists: $GIT_GLOBAL_CONFIG"
    ls -l "$GIT_GLOBAL_CONFIG"
else
    echo "Global Git config does not exist: $GIT_GLOBAL_CONFIG"
fi

# Check XDG Git config
if [ -f "$GIT_XDG_CONFIG" ]; then
    echo "XDG Git config exists: $GIT_XDG_CONFIG"
    ls -l "$GIT_XDG_CONFIG"
else
    echo "XDG Git config does not exist: $GIT_XDG_CONFIG"
fi
