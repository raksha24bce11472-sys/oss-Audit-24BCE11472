#!/bin/bash

read -p "Enter Tool name:" tool
read -p "What does freedom mean to you?" freedom
read -p "What do you want to build $build."> build

echo "I use $tool daily. Freedom means $freedom.I want to build $build."> manifesto.txt

echo"Manifesto saved in mainfesto.txt"
cat manifesto.txt
