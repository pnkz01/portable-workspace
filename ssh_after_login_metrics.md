## Custom information after logging into ssh

```
sudo hostnamectl set-hostname khodex

# Change welcome message if needed
sudo nano /etc/motd

# Custom after login metrics
sudo nano /etc/update-motd.d/10-uname

```

```
#!/bin/bash

# Collect system metrics
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}') # Sum of user and system CPU usage
MEMORY=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }') # Memory usage as a percentage
DISK=$(df -h / | awk 'NR==2 {print $5}') # Root filesystem usage as a percentage
UPTIME=$(uptime -p) # Human-readable uptime
TOP_PROCESSES=$(ps -eo pid,comm,%mem,%cpu --sort=-%cpu | head -n 6) # Top 5 processes

# Display the report on the terminal
echo "$(date)"
echo "---------------------------------"
echo "CPU Usage: $CPU%"
echo "Memory Usage: $MEMORY%"
echo "Disk Usage: $DISK"
echo "Uptime: $UPTIME"
echo ""
echo "Top 5 Processes by CPU Usage:"
echo "$TOP_PROCESSES"
echo ""
echo "Current active users"
echo "$(who)"
echo "---------------------------------"

```

```
sudo service ssh restart

# Login into new ssh shell to checkout

```
