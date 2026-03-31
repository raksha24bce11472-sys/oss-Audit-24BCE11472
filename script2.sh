#!/bin/bash
# Script 2: FOSS Package Inspector

PACKAGE="git"   # e.g. httpd, mysql, vlc, firefox, python3

# Check if package is installed
if command -v dpkg >/dev/null 2>&1; then
    if dpkg -l | grep -q "^ii  $PACKAGE"; then
        echo "$PACKAGE is installed."
        dpkg -s "$PACKAGE" | grep -E 'Package:|Version:|Maintainer:|Description:'
    else
        echo "$PACKAGE is NOT installed."
    fi
elif command -v rpm >/dev/null 2>&1; then
    if rpm -q "$PACKAGE" &>/dev/null; then
        echo "$PACKAGE is installed."
        rpm -qi "$PACKAGE" | grep -E 'Version|License|Summary'
    else
        echo "$PACKAGE is NOT installed."
    fi
else
    echo "No supported package manager found."
fi

# Add a case statement that prints a one-line
# philosophy note about the package based on its name
case "$PACKAGE" in
    httpd|apache2)
        echo "Apache: the web server that built the open internet."
        ;;
    mysql|mysql-server)
        echo "MySQL: open source at the heart of millions of apps."
        ;;
    python|python3)
        echo "Python: a language shaped by community, readability, and openness."
        ;;
    firefox)
        echo "Firefox: a nonprofit browser fighting for an open web."
        ;;
    vlc)
        echo "VLC: the media player built to play almost anything freely."
        ;;
    git)
        echo "Git: the version control tool that powers open collaboration."
        ;;
    *)
        echo "$PACKAGE: an important part of the FOSS ecosystem."
        ;;
esac
