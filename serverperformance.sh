#!/usr/bin/env bash

# ==============================================================================
# Server Performance Stats Script
# ==============================================================================

DIVIDER="------------------------------------------------------------"

echo "$DIVIDER"
echo "              SERVER PERFORMANCE STATS"
echo "              $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "$DIVIDER"

# 1. System Info
echo -e "\n[ SYSTEM INFORMATION ]"

if [ -f /etc/os-release ]; then
    OS_VERSION=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
else
    OS_VERSION=$(uname -srm)
fi

UPTIME=$(uptime -p 2>/dev/null || uptime | awk -F'( |,|:)+' '{print $6,$7",",$8,"hours,",$9,"minutes"}')
LOAD_AVG=$(awk '{print $1", "$2", "$3}' /proc/loadavg)
LOGGED_USERS_COUNT=$(who | wc -l)
LOGGED_USERS_LIST=$(who | awk '{print $1}' | sort -u | paste -sd ", " -)

printf "%-22s %s\n" "OS Version:" "$OS_VERSION"
printf "%-22s %s\n" "Uptime:" "$UPTIME"
printf "%-22s %s\n" "Load Average (1/5/15):" "$LOAD_AVG"
printf "%-22s %s (%s)\n" "Logged-in Users:" "$LOGGED_USERS_COUNT" "${LOGGED_USERS_LIST:-none}"

# Failed login attempts
if [ "$EUID" -eq 0 ]; then
    if command -v lastb >/dev/null 2>&1 && [ -r /var/log/btmp ]; then
        FAILED_LOGINS=$(lastb -n 1000 2>/dev/null | grep -v "^btmp begins" | grep -v "^$" | wc -l)
    elif [ -r /var/log/auth.log ]; then
        FAILED_LOGINS=$(grep -c "Failed password" /var/log/auth.log 2>/dev/null || echo 0)
    elif [ -r /var/log/secure ]; then
        FAILED_LOGINS=$(grep -c "Failed password" /var/log/secure 2>/dev/null || echo 0)
    else
        FAILED_LOGINS="N/A (log file not found)"
    fi
else
    FAILED_LOGINS="Run with sudo to view"
fi
printf "%-22s %s\n" "Failed Login Attempts:" "$FAILED_LOGINS"

# 2. Total CPU Usage
echo -e "\n[ CPU USAGE ]"
CPU_USAGE=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%.2f%%", ($2+$4-u1)*100/(t-t1); }' \
    <(grep '^cpu ' /proc/stat) <(sleep 1; grep '^cpu ' /proc/stat))
printf "%-22s %s\n" "Total CPU Usage:" "$CPU_USAGE"

# 3. Total Memory Usage
echo -e "\n[ MEMORY USAGE ]"
free -m | awk 'NR==2 {
    used=$3; free=$4; total=$2;
    used_pct=used*100/total;
    free_pct=free*100/total;
    printf "Total: %d MB | Used: %d MB (%.2f%%) | Free: %d MB (%.2f%%)\n", total, used, used_pct, free, free_pct
}'

# 4. Total Disk Usage
echo -e "\n[ DISK USAGE ]"
df -h --total -x tmpfs -x devtmpfs 2>/dev/null | awk '/^total/ {
    printf "Total: %s | Used: %s (%s) | Free: %s\n", $2, $3, $5, $4
}'

# 5. Top 5 Processes by CPU Usage
echo -e "\n[ TOP 5 PROCESSES BY CPU USAGE ]"
ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 6 | awk 'NR==1 {printf "%-8s %-12s %-8s %-8s %s\n", $1, $2, $3, $4, $5} NR>1 {printf "%-8s %-12s %-8s %-8s %s\n", $1, $2, $3"%", $4"%", $5}'

# 6. Top 5 Processes by Memory Usage
echo -e "\n[ TOP 5 PROCESSES BY MEMORY USAGE ]"
ps -eo pid,user,%mem,%cpu,comm --sort=-%mem | head -n 6 | awk 'NR==1 {printf "%-8s %-12s %-8s %-8s %s\n", $1, $2, $3, $4, $5} NR>1 {printf "%-8s %-12s %-8s %-8s %s\n", $1, $2, $3"%", $4"%", $5}'

echo -e "\n$DIVIDER"
