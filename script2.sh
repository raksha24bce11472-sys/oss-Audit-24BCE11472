#!/bin/bash

PACKAGE="python3"

if dpkg -l | grep -q $PACKAGE
then
    echo "$PACKAGE is installed"
    python3 --version
else
    echo "$PACKAGE is NOT installed"
fi
