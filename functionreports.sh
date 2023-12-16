#!/bin/bash


# Function to print section headers
print_header() {
    echo "======= $1 ======="
}

# Function to print key-value
print_kv() {
    echo "$1: $2"
}

# Function to generate CPU report
CPUFunc() {
    print_header "CPU Report"
    print_kv "CPU Manufacturer and Model" "$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)"
    print_kv "CPU Architecture" "$(lscpu | grep "Architecture" | cut -d':' -f2 | xargs)"
    print_kv "CPU Core Count" "$(lscpu | grep "Core(s) per socket" | cut -d':' -f2 | xargs)"
    print_kv "CPU Maximum Speed" "$(lscpu | grep "Max Speed" | cut -d':' -f2 | xargs)"
}

# Function to generate Computer report
CompFunc() {
    print_header "Computer Report"
    echo "Hostname: $(hostname)"
echo "OS: $(source /etc/os-release && echo $PRETTY_NAME)"
echo "Uptime: $(uptime -p)"
}

# Function to generate OS report
OSFunc() {
    print_header "OS Report"
    print_kv "Linux Distro" "$(lsb_release -d | cut -d':' -f2 | xargs)"
    print_kv "Distro Version" "$(lsb_release -r | cut -d':' -f2 | xargs)"
}

# Function to generate RAM report
RAMFunc() {
    print_header "RAM Report"
    cat /proc/cpuinfo | grep "model name" | head -n 1 | awk -F': ' '{print $2}'
echo "Speed:"
sudo lshw -class processor | awk '/description: CPU/{p=1} p && /size:/{print $2; exit}'
sudo lshw -class processor | awk '/description: CPU/{p=1} p && /capacity:/{print $2; exit}'
echo "RAM:"
cat sudo lshw -short -C memory | grep -i 'system memory' | awk '{print $3}'
}

# Function to generate Video report
VideoFunc() {
    echo "Disks:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,LABEL --exclude 7 | awk '!/loop/ {printf "%-8s %-8s %-4s %-8s %-7s %s\n", $1, $2, $3, $4, $5, $6}'
echo "Video card:"
lspci | grep -i "VGA" | awk -F': ' '{print $2}' | uniq
}

# Function to generate Disk report
DiskFunc() {
    print_header "Disk Report"
    echo "Disk Space:"
df -h
echo "Process Count:"
ps -e | wc -l
echo "Load Averages:"
uptime | awk -F'[a-z]:' '{print $2}'
echo "Memory Allocation:"
free -h | awk '/^Mem:/ {print "Type\tTotal\tAvailable"; print $1 "\t" $2 "\t" $7}'
echo "Listening Network Ports:"
ss -tuln | awk 'BEGIN {print "State\tRecv-Q\tSend-Q\tLocal Address:Port\tPeer Address:Port"} /LISTEN/ {print $1 "\t" $2 "\t" $3 "\t" $4 "\t\t" $5}'

}

# Function to generate Network report
NetworkFunc() {
    print_header "Network Report"
    echo "FQDN: $(hostname -f)"
echo "Host Address: $(hostname -I)"
echo "Gateway IP: $(ip route | awk '/default/ {print $3}')"
echo "DNS Server:"
cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}'
echo "Network Interface Information:"
sudo lshw -class network | grep -E 'description|product|vendor|physical id|logical name' | awk -F ':' '{print $1 ": " $2}'
echo "IP Address:"
ip -o addr show | awk '$3 == "inet" {print $4}'
}

