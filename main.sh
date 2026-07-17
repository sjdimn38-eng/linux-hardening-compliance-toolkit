#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/hardening.log"
REPORT_FILE="$PROJECT_ROOT/reports/compliance_report.html"

source "$PROJECT_ROOT/config/policy.conf"

SCORE=0
MAX_SCORE=7

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

run_check() {
    local script=$1
    log "Running $script"
    if bash "$PROJECT_ROOT/modules/$script"; then
        SCORE=$((SCORE + 1))
    fi
}

echo "========================================"
echo " Linux Hardening & Compliance Toolkit"
echo "========================================"

run_check ssh_hardening.sh
run_check firewall.sh
run_check selinux.sh
run_check auditd.sh
run_check password_policy.sh
run_check permissions.sh
run_check updates.sh

FINAL_SCORE=$(( SCORE * 100 / MAX_SCORE ))

echo
echo "Compliance Score: $FINAL_SCORE/100"

cat > "$REPORT_FILE" << HTML
<html>
<head>
<title>Compliance Report</title>
<style>
body { font-family: Arial; margin: 40px; }
h1 { color: #2c3e50; }
.score { font-size: 28px; color: #27ae60; }
</style>
</head>
<body>
<h1>Linux Hardening & Compliance Report</h1>
<p>Generated: $(date)</p>
<p class="score">Compliance Score: $FINAL_SCORE/100</p>
</body>
</html>
HTML

log "Report generated: $REPORT_FILE"
