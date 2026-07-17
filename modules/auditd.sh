#!/bin/bash

if systemctl is-active --quiet auditd; then
    echo "[PASS] auditd service is active"
    exit 0
else
    echo "[FAIL] auditd service is not active"
    exit 1
fi
