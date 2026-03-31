#!/bin/bash
# Script 5: Open Source Manifesto Generator
# Alias idea: you could create an alias like alias runmanifesto='./script5.sh'

echo "Answer three questions to generate your Git-inspired manifesto."
echo ""

read -p "1. Which Git command or feature do you use most often? " TOOL
read -p "2. In one word, what does open-source freedom mean to you? " FREEDOM
read -p "3. What kind of project would you build and share using Git? " BUILD

DATE=$(date '+%d %B %Y')
OUTPUT="manifesto_$(whoami).txt"

echo "Open Source Manifesto - $DATE" > "$OUTPUT"
echo "----------------------------------------" >> "$OUTPUT"
echo "I use Git feature/command '$TOOL' regularly because it helps me work in an open, trackable, and collaborative way. To me, freedom means '$FREEDOM', because open source gives people the right to study, modify, and share software. Using Git, I would like to build and openly share '$BUILD' so that others can learn from it, improve it, and contribute back to the community." >> "$OUTPUT"

echo ""
echo "Manifesto saved to $OUTPUT"
echo ""
cat "$OUTPUT"
