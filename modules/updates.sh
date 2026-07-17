#!/bin/bash

UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable)

if [ "$UPDATES" -eq 0 ]; then
    echo "[PASS] System is fully updated"
    exit 0
else
    echo "[FAIL] $UPDATES package(s) can be upgraded"
    exit 1
fi
