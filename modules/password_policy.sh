#!/bin/bash

if grep -q "^PASS_MIN_LEN" /etc/login.defs; then
    MIN_LEN=$(grep "^PASS_MIN_LEN" /etc/login.defs | awk '{print $2}')
    if [ "$MIN_LEN" -ge 12 ]; then
        echo "[PASS] Minimum password length is $MIN_LEN"
        exit 0
    fi
fi

echo "[FAIL] Minimum password length is less than 12"
exit 1
