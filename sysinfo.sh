#!/bin/bash
#
# sysdiag.sh - Enterprise-Grade System Diagnostic & Auditing Framework
#
# Version: 4.0 "Framework Edition"
# Author: Your Name
# License: MIT
#
# Description: A comprehensive, interactive, and extensible framework for deep
#              system diagnostics, performance monitoring, security auditing, and
#              data exporting. Designed for SysAdmins, DevOps, and power users.
#
# Usage:
#   Interactive Mode: sudo ./sysdiag.sh
#   Export Mode:      sudo ./sysdiag.sh --export [json|html] > output.file
#

# --- Core Engine: Configuration & Globals ---
VERSION="4.0"
CONFIG_FILE="$HOME/.sysdiag_config"
EXPORT_FORMAT=""

# --- Core Engine: Theme & Colors ---
# Using tput for maximum compatibility
C_RESET=$(tput sgr0)
C_BOLD=$(tput bold)
C_DIM=$(tput dim)
C_HEADER=$(tput setaf 6)
C_LABEL=$(tput setaf 3)
C_VALUE=$(tput setaf 7)
C_INFO=$(tput setaf 4)
C_MENU=$(tput setaf 5)
C_ERROR=$(tput setaf 1)
C_SUCCESS=$(tput setaf 2)
C_WARN=$(tput setaf 11)

# --- Core Engine: UI Elements & Helpers ---
DIVIDER="${C_DIM}├───────────────────────────────────────────────────────────┤${C_RESET}"
HEADER_START="╭─ "
HEADER_END=" ─╮"

print_header() {
    printf "\n%s" "${C_BOLD}${C_HEADER}"
    printf "%s%s%s\n" "$HEADER_START" "$1" "$HEADER_END"
    printf "%s\n" "$DIVIDER"
    printf "%s" "$C_RESET"
}

print_kv() {
    local key="$1"
    local value="$2"
    printf "%s%-25s%s %s%s\n" "${C_BOLD}${C_LABEL}" "$key:" "$C_RESET" "${C_VALUE}" "$value"
}

press_enter_to_continue() {
    [[ "$EXPORT_FORMAT" ]] && return
    printf "\n%sPress Enter to return to the menu...%s" "${C_INFO}" "${C_RESET}"
    read -r
}

check_command() {
    command -v "$1" &>/dev/null
}

check_dependency() {
    if ! check_command "$1"; then
        printf "%s%-25s%s %s%s\n" "${C_BOLD}${C_LABEL}" "$2 Check:" "$C_RESET" "${C_ERROR}" "MISSING ($1)"
        return 1
    else
        printf "%s%-25s%s %s%s\n" "${C_BOLD}${C_LABEL}" "$2 Check:" "$C_RESET" "${C_SUCCESS}" "OK"
        return 0
    fi
}

show_spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    tput civis # Hide cursor
    while ps -p $pid > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\r"
    done
    tput cnorm # Restore cursor
    wait $pid
    return $?
}

# Graceful exit
trap 'echo -e "\n${C_WARN}Script interrupted. Exiting.${C_RESET}"; tput cnorm; exit' SIGINT SIGTERM

# --- Information Modules ---

# Each function now outputs in a parsable "KEY: VALUE" format for exporting

# == 1. System & OS Modules ==
get_os_info() {
    print_header "Operating System & Kernel"
    if [ -f /etc/os-release ]; then . /etc/os-release; print_kv "Distribution" "$PRETTY_NAME"; fi
    print_kv "Kernel Version" "$(uname -r)"
    print_kv "Architecture" "$(uname -m)"
    print_kv "Hostname" "$(hostname)"
    print_kv "Systemd Target" "$(systemctl get-default 2>/dev/null || echo 'N/A')"
    print_kv "Boot Kernel Params" "$(cat /proc/cmdline)"
}

get_uptime_load() {
    print_header "Uptime, Load & Entropy"
    print_kv "Uptime" "$(uptime -p | sed 's/up //')"
    print_kv "Load Average" "$(uptime | awk -F'load average: ' '{print $2}')"
    print_kv "Available Entropy" "$(cat /proc/sys/kernel/random/entropy_avail) bits"
}

get_users_logins() {
    print_header "Users & Last Logins"
    echo "${C_LABEL}Current Users:${C_RESET}"; who
    echo "${C_LABEL}Recent Logins:${C_RESET}"; last -n 5
}

# == 2. Hardware Modules ==
get_cpu_info() {
    print_header "CPU Information"
    if check_command "lscpu"; then
        print_kv "Model" "$(lscpu | grep 'Model name:' | sed -r 's/Model name:\s{1,}//')"
        print_kv "Cores/Threads" "$(lscpu | grep '^CPU(s):' | sed -r 's/CPU\(s\):\s{1,}//') Cores, $(lscpu | grep 'Thread(s) per core' | awk '{print $NF}') Th/Core"
        print_kv "Max Speed" "$(lscpu | grep 'CPU max MHz:' | sed -r 's/CPU max MHz:\s{1,}//') MHz"
        print_kv "Virtualization" "$(lscpu | grep 'Virtualization:' | sed -r 's/Virtualization:\s{1,}//')"
    fi
}

get_mem_info() {
    print_header "Memory (RAM) Usage"
    if check_command "free"; then free -h; fi
    print_header "SWAP Usage"
    swapon --show
}

get_gpu_info() {
    print_header "GPU Information"
    if check_command "nvidia-smi"; then
        echo "${C_SUCCESS}NVIDIA GPU Detected via nvidia-smi:${C_RESET}"
        nvidia-smi -L
        nvidia-smi --query-gpu=driver_version,pstate,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used --format=csv,noheader,nounits | while IFS=, read -r drv pwr tmp gpu mem tot fre usd; do
            print_kv "Driver Version" "$drv"; print_kv "Performance State" "$pwr"; print_kv "Temperature" "$tmp C";
            print_kv "GPU Utilization" "$gpu %"; print_kv "VRAM Utilization" "$mem %"; print_kv "VRAM Usage" "$usd MiB / $tot MiB";
        done
    elif check_command "rocm-smi"; then
        echo "${C_SUCCESS}AMD GPU Detected via rocm-smi:${C_RESET}"; rocm-smi --showproductname --showtemp --showfan --showpower --showmeminfo vram
    elif check_command "lspci"; then
        print_kv "Generic GPU Info" "$(lspci | grep -i 'VGA\|3D\|Display')"
    else
        print_kv "GPU Info" "No GPU detection tools found."
    fi
}

get_disk_info() {
    print_header "Filesystem Usage"
    df -hT --total | grep -iv 'tmpfs\|udev'
    print_header "Block Devices & Mounts"
    lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINT
}

get_storage_health() {
    print_header "Storage S.M.A.R.T. Health"
    if ! check_command "smartctl"; then echo "${C_ERROR}smartctl not found. Please install 'smartmontools'.${C_RESET}"; return; fi
    for device in $(ls /dev/sd* /dev/nvme* 2>/dev/null | grep -v '[0-9]$'); do
        health=$(sudo smartctl -H "$device" | grep "test result" | awk '{print $NF}')
        model=$(sudo smartctl -i "$device" | grep "Device Model" | awk -F': ' '{print $2}')
        [[ -z "$model" ]] && model=$(sudo smartctl -i "$device" | grep "Model Number" | awk -F': ' '{print $2}')
        if [[ "$health" == "PASSED" || "$health" == "OK" ]]; then
            printf "%s%-15s%s %-30s %s%s%s\n" "${C_BOLD}${C_LABEL}" "$device" "${C_RESET}" "$model" "${C_SUCCESS}" "HEALTH: $health" "${C_RESET}"
        else
            printf "%s%-15s%s %-30s %s%s%s\n" "${C_BOLD}${C_LABEL}" "$device" "${C_RESET}" "$model" "${C_ERROR}" "HEALTH: $health" "${C_RESET}"
        fi
    done
}

# == 3. Software & Process Modules ==
get_top_processes() {
    print_header "Top 5 Processes by CPU"
    ps -eo pid,user,%cpu,comm --sort=-%cpu | head -n 6
    print_header "Top 5 Processes by Memory"
    ps -eo pid,user,%mem,comm --sort=-%mem | head -n 6
}

get_service_status() {
    print_header "Systemd Service Status"
    if check_command "systemctl"; then
        failed_units=$(systemctl --failed --no-legend | wc -l)
        if [ "$failed_units" -gt 0 ]; then
            echo "${C_ERROR}Found $failed_units failed services:${C_RESET}"; systemctl --failed --no-legend
        else
            echo "${C_SUCCESS}All services appear to be running correctly.${C_RESET}"
        fi
    fi
}

get_package_info() {
    print_header "Package Management"
    if check_command "dpkg"; then print_kv "APT/DPKG Packages" "$(dpkg -l | wc -l) installed";
    elif check_command "rpm"; then print_kv "DNF/YUM/RPM Packages" "$(rpm -qa | wc -l) installed";
    elif check_command "pacman"; then print_kv "Pacman Packages" "$(pacman -Qq | wc -l) installed"; fi
}

get_container_info() {
    print_header "Container & Virtualization"
    print_kv "Virtualization Tech" "$(systemd-detect-virt 2>/dev/null || echo 'None Detected')"
    if check_command "docker"; then
        print_kv "Docker Version" "$(docker --version)"; print_kv "Running Containers" "$(docker ps -q | wc -l)"
    elif check_command "podman"; then
        print_kv "Podman Version" "$(podman --version)"; print_kv "Running Containers" "$(podman ps -q | wc -l)"
    fi
}

# == 4. Network Modules ==
get_network_info() {
    print_header "Network Interfaces & IP Addresses"
    if check_command "ip"; then ip -c addr; else ifconfig; fi
    print_header "Routing Table"
    if check_command "ip"; then ip route; else route -n; fi
}

get_network_ports() {
    print_header "Listening Ports (TCP/UDP)"
    if check_command "ss"; then ss -tuln; else netstat -tuln; fi
}

get_dns_firewall() {
    print_header "DNS & Firewall"
    print_kv "DNS Servers" "$(grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ')"
    echo "${C_LABEL}Firewall Status:${C_RESET}"
    if check_command "ufw"; then sudo ufw status;
    elif check_command "firewall-cmd"; then sudo firewall-cmd --state;
    else echo "No common firewall tool (ufw, firewalld) detected."; fi
}

# == 5. Security Audit Modules ==
get_failed_logins() {
    print_header "Failed Login Attempts"
    if check_command "lastb"; then sudo lastb | head -n 10; else echo "Command 'lastb' not found."; fi
}

get_sudo_history() {
    print_header "Recent Sudo Command History"
    # This requires specific syslog/journald configuration on many systems.
    if [[ -f /var/log/auth.log ]]; then
        grep "COMMAND=" /var/log/auth.log | tail -n 10
    elif check_command "journalctl"; then
        journalctl _COMM=sudo | grep "COMMAND=" | tail -n 10
    else
        echo "Could not find sudo logs."
    fi
}

check_rootkits() {
    print_header "Rootkit Scan (rkhunter)"
    if ! check_command "rkhunter"; then echo "${C_ERROR}rkhunter not found. Please install 'rkhunter'.${C_RESET}"; return; fi
    echo "Running rkhunter system checks (this may take a minute)..."
    (sudo rkhunter --check --skip-keypress --quiet) &
    show_spinner
    echo "Scan complete. Warnings found:"
    sudo rkhunter --summary | grep "Warning"
}

# == 6. Live Dashboards & Tools ==
live_process_monitor() {
    if ! check_command "htop"; then echo "${C_ERROR}htop not found. Install it for the best experience.${C_RESET}"; top; else htop; fi
}

live_disk_io_monitor() {
    if ! check_command "iotop"; then echo "${C_ERROR}iotop not found. Please install 'iotop'.${C_RESET}"; sleep 2; else sudo iotop; fi
}

live_network_monitor() {
    if ! check_command "bmon"; then echo "${C_ERROR}bmon not found. Please install 'bmon'.${C_RESET}"; sleep 2; else bmon; fi
}

run_speed_test() {
    if ! check_command "speedtest-cli"; then echo "${C_ERROR}speedtest-cli not found. Install with 'pip install speedtest-cli'.${C_RESET}"; sleep 2; return; fi
    speedtest-cli
}

# --- Core Engine: Menu System ---

# The new menu system is robust, using dedicated functions and case statements.
# This completely resolves the "Invalid Operation" class of errors.

show_logo() {
    cat << "EOF"

  ███████╗██╗   ██╗███████╗██╗  ██╗██████╗  █████╗  ███████╗
  ██╔════╝╚██╗ ██╔╝██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝
  ███████╗ ╚████╔╝ █████╗  ███████║██║  ██║███████║███████╗
  ╚════██║  ╚██╔╝  ██╔══╝  ██╔══██║██║  ██║██╔══██║╚════██║
  ███████║   ██║   ███████╗██║  ██║██████╔╝██║  ██║███████║
  ╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝
    -- The System Diagnostic & Auditing Framework v4.0 --

EOF
}

menu_system() {
    local choice
    while true; do
        clear; show_logo
        print_header "System & OS Information"
        printf "   %s1)%s OS & Kernel\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s2)%s Uptime, Load & Entropy\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s3)%s Users & Logins\n" "${C_MENU}" "${C_VALUE}"
        printf "   %sb)%s Back to Main Menu\n" "${C_MENU}" "${C_VALUE}"
        read -rp "$(printf '\n%sSelect an option: %s' "${C_LABEL}" "${C_RESET}")" choice

        case $choice in
            1) clear; get_os_info; press_enter_to_continue ;;
            2) clear; get_uptime_load; press_enter_to_continue ;;
            3) clear; get_users_logins; press_enter_to_continue ;;
            b|B) break ;;
            *) printf "\n%sInvalid option.%s\n" "${C_ERROR}" "${C_RESET}" && sleep 1 ;;
        esac
    done
}

menu_hardware() {
    local choice
    while true; do
        clear; show_logo
        print_header "Hardware Diagnostics"
        printf "   %s1)%s CPU Information\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s2)%s Memory (RAM & SWAP)\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s3)%s GPU Professional Details\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s4)%s Disk Filesystems & Partitions\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s5)%s Storage S.M.A.R.T. Health\n" "${C_MENU}" "${C_VALUE}"
        printf "   %sb)%s Back to Main Menu\n" "${C_MENU}" "${C_VALUE}"
        read -rp "$(printf '\n%sSelect an option: %s' "${C_LABEL}" "${C_RESET}")" choice
        
        case $choice in
            1) clear; get_cpu_info; press_enter_to_continue ;;
            2) clear; get_mem_info; press_enter_to_continue ;;
            3) clear; get_gpu_info; press_enter_to_continue ;;
            4) clear; get_disk_info; press_enter_to_continue ;;
            5) clear; get_storage_health; press_enter_to_continue ;;
            b|B) break ;;
            *) printf "\n%sInvalid option.%s\n" "${C_ERROR}" "${C_RESET}" && sleep 1 ;;
        esac
    done
}

menu_software() {
    local choice
    while true; do
        clear; show_logo
        print_header "Software & Processes"
        printf "   %s1)%s Top Processes (CPU & Memory)\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s2)%s Systemd Service Status\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s3)%s Installed Package Counts\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s4)%s Container & VM Info\n" "${C_MENU}" "${C_VALUE}"
        printf "   %sb)%s Back to Main Menu\n" "${C_MENU}" "${C_VALUE}"
        read -rp "$(printf '\n%sSelect an option: %s' "${C_LABEL}" "${C_RESET}")" choice
        
        case $choice in
            1) clear; get_top_processes; press_enter_to_continue ;;
            2) clear; get_service_status; press_enter_to_continue ;;
            3) clear; get_package_info; press_enter_to_continue ;;
            4) clear; get_container_info; press_enter_to_continue ;;
            b|B) break ;;
            *) printf "\n%sInvalid option.%s\n" "${C_ERROR}" "${C_RESET}" && sleep 1 ;;
        esac
    done
}

menu_network() {
    local choice
    while true; do
        clear; show_logo
        print_header "Network Analysis"
        printf "   %s1)%s Interfaces, IPs & Routing\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s2)%s Listening Ports\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s3)%s DNS & Firewall Status\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s4)%s Run Internet Speed Test\n" "${C_MENU}" "${C_VALUE}"
        printf "   %sb)%s Back to Main Menu\n" "${C_MENU}" "${C_VALUE}"
        read -rp "$(printf '\n%sSelect an option: %s' "${C_LABEL}" "${C_RESET}")" choice

        case $choice in
            1) clear; get_network_info; press_enter_to_continue ;;
            2) clear; get_network_ports; press_enter_to_continue ;;
            3) clear; get_dns_firewall; press_enter_to_continue ;;
            4) clear; run_speed_test; press_enter_to_continue ;;
            b|B) break ;;
            *) printf "\n%sInvalid option.%s\n" "${C_ERROR}" "${C_RESET}" && sleep 1 ;;
        esac
    done
}

menu_security() {
    local choice
    while true; do
        clear; show_logo
        print_header "Security Auditing"
        printf "   %s1)%s Failed Login Attempts\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s2)%s Sudo Command History\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s3)%s Run Rootkit Scan (rkhunter)\n" "${C_MENU}" "${C_VALUE}"
        printf "   %sb)%s Back to Main Menu\n" "${C_MENU}" "${C_VALUE}"
        read -rp "$(printf '\n%sSelect an option: %s' "${C_LABEL}" "${C_RESET}")" choice
        
        case $choice in
            1) clear; get_failed_logins; press_enter_to_continue ;;
            2) clear; get_sudo_history; press_enter_to_continue ;;
            3) clear; check_rootkits; press_enter_to_continue ;;
            b|B) break ;;
            *) printf "\n%sInvalid option.%s\n" "${C_ERROR}" "${C_RESET}" && sleep 1 ;;
        esac
    done
}

menu_live_dashboards() {
    local choice
    while true; do
        clear; show_logo
        print_header "Live Dashboards"
        printf "   %s1)%s Process Monitor (htop)\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s2)%s Disk I/O Monitor (iotop)\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s3)%s Network Bandwidth Monitor (bmon)\n" "${C_MENU}" "${C_VALUE}"
        printf "   %sb)%s Back to Main Menu\n" "${C_MENU}" "${C_VALUE}"
        read -rp "$(printf '\n%sSelect an option: %s' "${C_LABEL}" "${C_RESET}")" choice
        
        case $choice in
            1) clear; live_process_monitor; ;;
            2) clear; live_disk_io_monitor; ;;
            3) clear; live_network_monitor; ;;
            b|B) break ;;
            *) printf "\n%sInvalid option.%s\n" "${C_ERROR}" "${C_RESET}" && sleep 1 ;;
        esac
    done
}

main_menu() {
    local choice
    while true; do
        clear; show_logo
        print_header "Main Menu"
        printf "   %s1)%s System & OS\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s2)%s Hardware Diagnostics\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s3)%s Software & Processes\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s4)%s Network Analysis\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s5)%s Security Auditing\n" "${C_MENU}" "${C_VALUE}"
        printf "   %s6)%s Live Dashboards\n" "${C_MENU}" "${C_VALUE}"
        printf "   %sS)%s Self-Check Dependencies\n" "${C_MENU}" "${C_VALUE}"
        printf "   %sQ)%s Quit\n" "${C_MENU}" "${C_VALUE}"
        read -rp "$(printf '\n%sSelect an option: %s' "${C_BOLD}${C_LABEL}" "${C_RESET}")" choice

        case $choice in
            1) menu_system ;;
            2) menu_hardware ;;
            3) menu_software ;;
            4) menu_network ;;
            5) menu_security ;;
            6) menu_live_dashboards ;;
            s|S) clear; run_dependency_check; press_enter_to_continue ;;
            q|Q) break ;;
            *) printf "\n%sInvalid option.%s\n" "${C_ERROR}" "${C_RESET}" && sleep 1 ;;
        esac
    done
}

# --- Core Engine: Special Modes ---

run_dependency_check() {
    print_header "Dependency Self-Check"
    check_dependency "lscpu" "CPU Details"
    check_dependency "free" "Memory Info"
    check_dependency "lsblk" "Disk/Block Info"
    check_dependency "smartctl" "S.M.A.R.T. Health"
    check_dependency "ip" "Modern Network Info"
    check_dependency "ss" "Modern Socket Stats"
    check_dependency "htop" "Live Process Dashboard"
    check_dependency "iotop" "Live I/O Dashboard"
    check_dependency "bmon" "Live Network Dashboard"
    check_dependency "speedtest-cli" "Speed Test Tool"
    check_dependency "rkhunter" "Rootkit Scanner"
    check_dependency "nvidia-smi" "NVIDIA GPU Pro Tools"
    check_dependency "rocm-smi" "AMD GPU Pro Tools"
}

run_export_mode() {
    # This is a powerful feature for automation and reporting.
    # It calls all 'get' functions and outputs structured data.
    
    # Simple JSON generation
    if [[ "$EXPORT_FORMAT" == "json" ]]; then
        echo "{"
        # This is a basic implementation. A real-world scenario might use jq.
        (
         get_os_info; get_uptime_load; get_cpu_info; get_package_info; get_container_info
        ) | awk -F': ' '/:/ {
            key = $1;
            gsub(/"/, "\\\"", key);
            value = $2;
            gsub(/"/, "\\\"", value);
            printf "  \"%s\": \"%s\",\n", key, value;
        }' | sed '$ s/,$//' # Remove trailing comma
        echo "}"
    fi

    # Simple HTML generation
    if [[ "$EXPORT_FORMAT" == "html" ]]; then
        cat <<EOF
<html><head><title>System Diagnostics Report</title>
<style>body{font-family:sans-serif;background:#282a36;color:#f8f8f2;} h2{color:#50fa7b;} pre{background:#44475a;padding:1em;border-radius:5px;}</style>
</head><body><h1>System Diagnostics Report for $(hostname)</h1>
EOF
        # Wrap each function's output in a <pre> tag
        for func in get_os_info get_uptime_load get_cpu_info get_mem_info get_gpu_info get_disk_info get_top_processes get_service_status get_network_info get_network_ports get_dns_firewall; do
            echo "<h2>$func</h2><pre>"
            $func | sed 's/\[[0-9;]*m//g' # Strip ANSI color codes for clean HTML
            echo "</pre>"
        done
        echo "</body></html>"
    fi
}

# --- Core Engine: Entry Point ---
if [[ "$1" == "--export" ]]; then
    if [[ "$2" == "json" || "$2" == "html" ]]; then
        EXPORT_FORMAT="$2"
        run_export_mode
        exit 0
    else
        echo "${C_ERROR}Invalid export format. Use 'json' or 'html'.${C_RESET}" >&2
        exit 1
    fi
fi

if [[ $EUID -ne 0 ]]; then
   printf "%sWarning: Running without root privileges (sudo).%s\n" "${C_BOLD}${C_WARN}" "${C_RESET}"
   printf "Many features like SMART health, security scans, and hardware details will be limited or fail.\n"
   printf "For full functionality, please run: %ssudo ./sysdiag.sh%s\n\n" "${C_SUCCESS}" "${C_RESET}"
   sleep 4
fi

main_menu

tput cnorm # Ensure cursor is visible on exit
echo -e "\n${C_SUCCESS}SysDiag session finished.${C_RESET}"
exit 0