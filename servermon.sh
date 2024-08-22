#!/bin/bash

# Services to monitor
services=("httpd" "mysqld" "named" "exim" "dovecot" "spamd" "clamd" "csf" "php-fpm")
admin_email="admin@example.com" 
for service in "${services[@]}"
do
    if systemctl is-active --quiet $service; then
        echo "$service is running."
    else
        echo "$service is not running, attempting to restart."
        # Attempt to restart the service
        systemctl restart $service
        if systemctl is-active --quiet $service; then
            echo "$service was successfully restarted." | mail -s "$service restarted" $admin_email
        else
            echo "$service failed to restart!" | mail -s "$service failed to restart" $admin_email
        fi
    fi
done

# Thresholds for alerts
CPU_THRESHOLD=80
MEM_THRESHOLD=90
DISK_THRESHOLD=90
admin_email="admin@example.com"

# Check CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
if (( ${CPU_USAGE%.*} > CPU_THRESHOLD )); then
    echo "CPU usage is at $CPU_USAGE%!" | mail -s "High CPU Usage Alert" $admin_email
fi

# Check memory usage
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
if (( ${MEM_USAGE%.*} > MEM_THRESHOLD )); then
    echo "Memory usage is at $MEM_USAGE%!" | mail -s "High Memory Usage Alert" $admin_email
fi

# Check disk usage
DISK_USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
if (( DISK_USAGE > DISK_THRESHOLD )); then
    echo "Disk usage is at $DISK_USAGE%!" | mail -s "High Disk Usage Alert" $admin_email
fi
