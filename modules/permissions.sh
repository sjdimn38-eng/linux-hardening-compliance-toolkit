#!/bin/bash

WEAK=$(find /home/sajid -maxdepth 3 -type f -perm -002 2>/dev/null | wc -l)

if [ "$WEAK" -eq 0 ]; then
    echo "[PASS] No world-writable files found"
    exit 0
else
    echo "[FAIL] Found $WEAK world-writable file(s)"
    exit 1
fi
