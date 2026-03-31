#!/bin/bash

echo "----- Disk Audit -----"
echo ""

for dir in /etc /home /usr/bin
do
    echo "Checking: $dir"
    echo "Disk Usage:"
    du -sh "$dir" 2>/dev/null
    echo "Permissions & Owner:"
    ls -ld "$dir"
    echo "----------------------------"
    echo ""
done

# Additional check for Python config directory
echo "----- Python Configuration Audit -----"
echo ""
PYTHON_CONFIG="/etc/python3"
if [ -d "$PYTHON_CONFIG" ]; then
    echo "Checking: $PYTHON_CONFIG"
    du -sh "$PYTHON_CONFIG" 2>/dev/null
    ls -ld "$PYTHON_CONFIG"
    echo ""
    echo "Contents (first 10 items):"
    ls -la "$PYTHON_CONFIG" | head -10
else
    echo "$PYTHON_CONFIG does not exist"
fi
