#!/bin/bash

CONFIG="/etc/ssh/sshd_config"

if grep -qi "^PermitRootLogin no" "$CONFIG" 2>/dev/null; then
    echo "[PASS] Root SSH login disabled"
    exit 0
else
    echo "[FAIL] Root SSH login enabled or not configured"
    exit 1
fi
