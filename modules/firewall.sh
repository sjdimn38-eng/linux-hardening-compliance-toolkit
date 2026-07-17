#!/bin/bash

if command -v firewall-cmd >/dev/null 2>&1; then
    if firewall-cmd --state 2>/dev/null | grep -q running; then
        echo "[PASS] firewalld is running"
        exit 0
    fi
fi

if command -v ufw >/dev/null 2>&1; then
    if ufw status | grep -q "Status: active"; then
        echo "[PASS] UFW is active"
        exit 0
    fi
fi

echo "[FAIL] No active firewall detected"
exit 1
