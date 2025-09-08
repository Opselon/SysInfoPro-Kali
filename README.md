# SysInfoPro - The Professional's System Diagnostic Toolkit

![SysInfoPro Logo](https://raw.githubusercontent.com/Opselon/SysInfoPro-Kali/main/assets/sysinfopro_logo.png) <!-- You will need to create and upload this image to your repo -->

**SysInfoPro** is an enterprise-grade, interactive command-line framework for deep system diagnostics, performance monitoring, security auditing, and data exporting. Designed for SysAdmins, DevOps engineers, and security professionals, it provides a comprehensive overview of your system's hardware, software, network, and security posture in a clean, modern interface.

While built with the power of Kali Linux in mind, it is compatible with most modern Debian, RHEL, and Arch-based Linux distributions.

---

## ❯ Features

SysInfoPro is organized into logical, feature-rich modules:

<details>
<summary><strong>🖥️ System & OS Information</strong></summary>

-   Full OS, Distribution, and Kernel Details
-   System Uptime, Load Average & Real-time Entropy
-   Currently Logged-in Users & Last Login History
-   Security Module Status (SELinux/AppArmor)
-   World Clock for Major Timezones
</details>

<details>
<summary><strong>⚙️ Hardware Diagnostics</strong></summary>

-   **Pro GPU Monitoring**: Auto-detects NVIDIA/AMD GPUs and uses `nvidia-smi`/`rocm-smi` for detailed stats on temperature, fan speed, power draw, and VRAM usage.
-   Detailed CPU Information (Model, Cores, Threads, Virtualization)
-   Comprehensive Memory (RAM) and SWAP Usage
-   Disk Filesystem Usage & Block Device Layout (`lsblk`)
-   **S.M.A.R.T. Health Status**: Checks the health of all detected storage devices.
-   Motherboard & BIOS/UEFI Information (`dmidecode`)
</details>

<details>
<summary><strong>📦 Software & Processes</strong></summary>

-   Top Processes sorted by CPU and Memory usage
-   Systemd Service Status (highlights failed units)
-   Installed Package Counts for major package managers (APT, DNF/YUM, Pacman)
-   Container & Virtualization Detection (Docker, Podman, systemd-detect-virt)
</details>

<details>
<summary><strong>🌐 Network Analysis</strong></summary>

-   Full listing of Network Interfaces, IP Addresses, and Routing Tables
-   List of all Listening TCP/UDP Ports
-   Current DNS Server Configuration
-   Firewall Status detection for `ufw`, `firewalld`, and `iptables`
-   **Internet Speed Test**: On-demand bandwidth test using `speedtest-cli`.
</details>

<details>
<summary><strong>🛡️ Security Auditing</strong></summary>

-   List of recent failed login attempts (`lastb`)
-   Recent `sudo` command execution history
-   On-demand Rootkit Scanning with `rkhunter`
</_details_>

<details>
<summary><strong>📊 Live Dashboards</strong></summary>

-   **Process Monitor**: Live, interactive process list using `htop`.
-   **Disk I/O Monitor**: Real-time disk read/write activity with `iotop`.
-   **Network Bandwidth Monitor**: Live network traffic visualization with `bmon`.
</details>

<details>
<summary><strong>🚀 Framework Features</strong></summary>

-   **Data Export**: Export full system reports in **JSON** or **HTML** format for automation and record-keeping.
-   **Dependency Self-Check**: A built-in tool to verify that all necessary helper utilities are installed.
-   **Robust & Intuitive UI**: A hierarchical menu system that is fast, clear, and prevents user error.
-   **Root Privilege Awareness**: The script warns you if it's not run with `sudo`, as some features require elevated permissions.
</details>

---

## ❯ Preview

![SysInfoPro Menu Preview](https://raw.githubusercontent.com/Opselon/SysInfoPro-Kali/main/assets/sysinfopro_logo.png) <!-- You will need to create and upload this image to your repo -->

---

## ❯ Fast Run Commands (Installation)

Get up and running in under a minute. Simply clone the repository, make the script executable, and run it with `sudo` for full functionality.

```bash
# 1. Clone the repository
git clone https://github.com/Opselon/SysInfoPro-Kali.git

# 2. Navigate into the directory
cd SysInfoPro-Kali

# 3. Make the script executable
chmod +x sysinfo.sh

# 4. Run the script with root privileges
sudo ./sysinfo.sh
