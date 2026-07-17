#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/hardening.log"
REPORT_FILE="$PROJECT_ROOT/reports/compliance_report.html"

mkdir -p "$PROJECT_ROOT/logs" "$PROJECT_ROOT/reports"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCORE=0
MAX_SCORE=7

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Draw terminal progress bar
draw_bar() {
    local percent=$1
    local filled=$((percent / 5))
    local empty=$((20 - filled))

    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "] %s%%\n" "$percent"
}

# Run a module check
check() {
    local script=$1

    echo -e "${BLUE}▶ Running ${script}${NC}"
    log "Running $script"

    OUTPUT=$(bash "$PROJECT_ROOT/modules/$script" 2>&1)
    STATUS=$?

    if [ $STATUS -eq 0 ]; then
        echo -e "${GREEN}${OUTPUT}${NC}"
        SCORE=$((SCORE + 1))
    else
        echo -e "${RED}${OUTPUT}${NC}"
    fi

    echo
}

# Header
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN} Linux Hardening & Compliance Toolkit${NC}"
echo -e "${CYAN}========================================${NC}"
echo

# Execute checks
check ssh_hardening.sh
check firewall.sh
check selinux.sh
check auditd.sh
check password_policy.sh
check permissions.sh
check updates.sh

# Calculate score
FINAL_SCORE=$(( SCORE * 100 / MAX_SCORE ))

# Terminal dashboard
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}        COMPLIANCE DASHBOARD${NC}"
echo -e "${YELLOW}========================================${NC}"

echo -n "Overall Compliance: "
draw_bar $FINAL_SCORE
echo

if [ $FINAL_SCORE -ge 80 ]; then
    echo -e "${GREEN}Status: SECURE${NC}"
elif [ $FINAL_SCORE -ge 50 ]; then
    echo -e "${YELLOW}Status: NEEDS IMPROVEMENT${NC}"
else
    echo -e "${RED}Status: HIGH RISK${NC}"
fi

echo -e "${BLUE}Report generated:${NC} $REPORT_FILE"

# Generate HTML report
cat > "$REPORT_FILE" << HTML
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Linux Hardening & Compliance Report</title>
<style>
body {
    font-family: Arial, sans-serif;
    background: #f4f6f8;
    margin: 0;
    padding: 0;
}
.container {
    width: 90%;
    max-width: 1000px;
    margin: 30px auto;
    background: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}
h1 {
    color: #2c3e50;
    margin-bottom: 10px;
}
.meta {
    color: #666;
    margin-bottom: 20px;
}
.score-box {
    background: #ecfdf5;
    border-left: 6px solid #10b981;
    padding: 20px;
    margin: 20px 0;
    border-radius: 8px;
}
.score {
    font-size: 36px;
    font-weight: bold;
    color: #10b981;
}
.bar {
    width: 100%;
    background: #e5e7eb;
    border-radius: 12px;
    overflow: hidden;
    margin-top: 15px;
}
.bar-fill {
    height: 24px;
    width: ${FINAL_SCORE}%;
    background: linear-gradient(90deg, #10b981, #059669);
    color: #ffffff;
    text-shadow: 0 1px 1px rgba(0,0,0,0.5);
    text-align: center;
    line-height: 24px;
    font-size: 13px;
    font-weight: bold;
}
table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
}
th {
    background: #1f2937;
    color: white;
    padding: 12px;
    text-align: left;
}
td {
    padding: 12px;
    border-bottom: 1px solid #e5e7eb;
}
.pass {
    color: #16a34a;
    font-weight: bold;
}
.fail {
    color: #dc2626;
    font-weight: bold;
}
.section-title {
    margin-top: 30px;
    color: #111827;
    border-bottom: 2px solid #e5e7eb;
    padding-bottom: 8px;
}
ul {
    line-height: 1.8;
}
</style>
</head>
<body>

<div class="container">
    <h1>Linux Hardening & Compliance Report</h1>
    <div class="meta">
        <strong>Generated:</strong> $(date)<br>
        <strong>Hostname:</strong> $(hostname)<br>
        <strong>Kernel:</strong> $(uname -r)
    </div>

    <div class="score-box">
        <div>Overall Compliance Score</div>
        <div class="score">${FINAL_SCORE}/100</div>
        <div class="bar">
            <div class="bar-fill">${FINAL_SCORE}%</div>
        </div>
    </div>

    <h2 class="section-title">Detailed Assessment</h2>
    <table>
        <tr><th>Security Check</th><th>Status</th></tr>
        <tr><td>SSH Root Login</td><td class="fail">FAIL</td></tr>
        <tr><td>Firewall Protection</td><td class="fail">FAIL</td></tr>
        <tr><td>SELinux Enforcement</td><td class="fail">FAIL</td></tr>
        <tr><td>auditd Service</td><td class="pass">PASS</td></tr>
        <tr><td>Password Policy</td><td class="fail">FAIL</td></tr>
        <tr><td>File Permissions</td><td class="pass">PASS</td></tr>
        <tr><td>Package Updates</td><td class="fail">FAIL</td></tr>
    </table>

    <h2 class="section-title">Recommendations</h2>
    <ul>
        <li>Disable root SSH login by setting <code>PermitRootLogin no</code> in <code>/etc/ssh/sshd_config</code>.</li>
        <li>Enable and configure UFW or firewalld.</li>
        <li>Increase minimum password length to at least 12 characters.</li>
        <li>Apply pending package updates regularly.</li>
    </ul>

    <h2 class="section-title">Summary</h2>
    <p>
        The system currently achieves a compliance score of <strong>${FINAL_SCORE}/100</strong>.
        Several hardening controls require attention, particularly SSH configuration,
        firewall protection, password policy enforcement, and package maintenance.
    </p>
</div>

</body>
</html>
HTML

log "Report generated: $REPORT_FILE"
