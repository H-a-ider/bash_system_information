#!/bin/bash

# Function to calculate percentage
calculate_percentage() {
    local total=$1
    local used=$2
    local percentage=$(echo "scale=2; ($used / $total) * 100" | bc -l)
    echo "$percentage"
}

used_memory=$(free | awk '/Mem/{print $3}')
total_memory=$(free | awk '/Mem/{print $2}')
cpu=$(top -bn1 | awk '/%Cpu/{print $2}') 
used_disk=$(df -h --total | awk '/total/ {print $3}')
total_disk=$(df -h --total | awk '/total/ {print $2}')
running_services=$(ps aux)

recipient_email=""
subject="Alert from Bash Script"
message=""
threshold=80

# Calculate memory percentage
memory_percentage=$(calculate_percentage "$total_memory" "$used_memory")

# Calculate disk percentage
disk_percentage=$(calculate_percentage "$total_disk" "$used_disk")

if (( $(echo "$memory_percentage >= $threshold" | bc -l) )); then
    message+="Memory Alert\n"
fi

if (( $(echo "$cpu >= $threshold" | bc -l) )); then
    message+="CPU Alert\n"
fi

if (( $(echo "$disk_percentage >= $threshold" | bc -l) )); then
    message+="Disk Memory Alert\n"
fi


if [ -n "$message" ]; then
    echo -e "$message" | mail -s "$subject" "$recipient_email"
    echo "Alert Email sent successfully"
else
    echo "No alerts to send."
fi

# Display collected information
echo "Used Memory: $used_memory"
echo "Total Memory: $total_memory"
echo "CPU: $cpu"
echo "Used Disk Space: $used_disk"
echo "Total Disk Space: $total_disk"
echo "Running Services:"
echo "$running_services" | less
