#!/bin/bash

# Prompt for subnet
read -p "Enter subnet to scan (e.g., 192.168.1.0/24): " SUBNET

# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
    echo "Error: nmap is not installed or not in PATH."
    exit 1
fi

# Discovery scan
echo "Scanning $SUBNET for live hosts..."
nmap -sn "$SUBNET" -oG temp_results.txt > /dev/null

# Extract live IPs
echo "Live hosts found:"
grep "Status: Up" temp_results.txt | awk '{print $2}' > live_hosts.txt
cat live_hosts.txt

# Clean up temporary file
rm -f temp_results.txt

echo
echo "Starting aggressive scans on each host..."
echo

# Clear previous summary
echo "Open Port Summary:" > scan_summary.txt

# Scan each host aggressively
while read -r IP; do
    echo "Scanning $IP ..."
    nmap -A "$IP" -oN "scan_$IP.txt"
    echo "Scan complete for $IP."
    echo "$IP scan saved to scan_$IP.txt" >> scan_summary.txt
done < live_hosts.txt

echo
echo "All scans completed. Summary:"
cat scan_summary.txt
