#!/bin/bash

if command -v getenforce >/dev/null 2>&1; then
    MODE=$(getenforce)
    if [ "$MODE" = "Enforcing" ]; then
        echo "[PASS] SELinux is Enforcing"
        exit 0
    else
        echo "[FAIL] SELinux mode: $MODE"
        exit 1
    fi
else
    echo "[FAIL] SELinux not installed"
    exit 1
fi
