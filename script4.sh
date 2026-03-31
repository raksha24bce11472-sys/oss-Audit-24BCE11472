#!/bin/bash
# Script 4: Log File Analyzer
# Usage: ./script4.sh /var/log/dpkg.log git

LOGFILE=${1:-/var/log/dpkg.log}
KEYWORD=${2:-KEYWORD}
COUNT=0

echo "=================================="
echo "        Log File Analyzer"
echo "=================================="
echo "Log file : $LOGFILE"
echo "Keyword  : $KEYWORD"
echo ""

# Check if file exists
if [ ! -e "$LOGFILE" ]; then
    echo "Error: File $LOGFILE not found."
    exit 1
fi

# If current file is empty, try rotated logs
if [ ! -s "$LOGFILE" ]; then
    echo "Current log file is empty. Checking rotated logs..."
    if [ -f "${LOGFILE}.1" ]; then
        LOGFILE="${LOGFILE}.1"
        echo "Using rotated log: $LOGFILE"
    elif [ -f "${LOGFILE}.1.gz" ]; then
        LOGFILE="${LOGFILE}.1.gz"
        echo "Using compressed rotated log: $LOGFILE"
    else
        echo "No usable rotated log found for $LOGFILE"
        exit 1
    fi
fi

echo ""

# Read normal text log
if [[ "$LOGFILE" != *.gz ]]; then
    while IFS= read -r LINE; do
        if echo "$LINE" | grep -iq "$KEYWORD"; then
            COUNT=$((COUNT + 1))
        fi
    done < "$LOGFILE"

    echo "Keyword '$KEYWORD' found $COUNT times in $LOGFILE"
    echo ""
    echo "Last 5 matching lines:"
    grep -i "$KEYWORD" "$LOGFILE" | tail -5

# Read compressed log
else
    while IFS= read -r LINE; do
        if echo "$LINE" | grep -iq "$KEYWORD"; then
            COUNT=$((COUNT + 1))
        fi
    done < <(zcat "$LOGFILE")

    echo "Keyword '$KEYWORD' found $COUNT times in $LOGFILE"
    echo ""
    echo "Last 5 matching lines:"
    zgrep -i "$KEYWORD" "$LOGFILE" | tail -5
fi
