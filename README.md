<!-- HEADER -->
<div align="center">

  <!-- BADGES -->
  <p>
    <a href="https://github.com/Opselon/SysInfoPro-Kali/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Opselon/SysInfoPro-Kali?style=for-the-badge&color=blue" alt="License" title="Project License: Indicates the MIT License, allowing open use and modification. Click to view license details."></a>
    <a href="https://github.com/Opselon/SysInfoPro-Kali/stargazers"><img src="https://img.shields.io/github/stars/Opselon/SysInfoPro-Kali?style=for-the-badge&logo=github" alt="GitHub Stars" title="GitHub Stars: Shows how many users have starred this repository, reflecting its popularity. Click to see stargazers."></a>
    <a href="https://github.com/Opselon/SysInfoPro-Kali/network/members"><img src="https://img.shields.io/github/forks/Opselon/SysInfoPro-Kali?style=for-the-badge&logo=github" alt="GitHub Forks" title="GitHub Forks: Displays the number of times this repository has been forked by the community. Click to view forks."></a>
    <a href="https://github.com/Opselon/SysInfoPro-Kali/issues"><img src="https://img.shields.io/github/issues/Opselon/SysInfoPro-Kali?style=for-the-badge&logo=github" alt="Open Issues" title="Open Issues: Shows the number of currently open issues, indicating active development and bug tracking. Click to view issues."></a>
    <a href="https://github.com/Opselon/SysInfoPro-Kali"><img src="https://img.shields.io/github/languages/top/Opselon/SysInfoPro-Kali?style=for-the-badge&color=informational" alt="Top Language" title="Top Language: Displays Shell (Bash) as the primary language, reflecting its nature as a powerful command-line script."></a>
    <a href="https://github.com/Opselon/SysInfoPro-Kali/commits/main"><img src="https://img.shields.io/github/last-commit/Opselon/SysInfoPro-Kali?style=for-the-badge&color=success" alt="Last Commit" title="Last Commit: Shows how recently the codebase was updated, indicating project activity and maintenance. Click to view commit history."></a>
  </p>
</div>

<!-- HERO SECTION -->
<table align="center">
  <tr>
    <td align="center" width="200">
      <img src="https://raw.githubusercontent.com/Opselon/SysInfoPro-Kali/main/assets/sysinfopro_logo.png" alt="SysInfoPro Logo" />
    </td>
    <td>
      <h1>SysInfoPro</h1>
      <h3>Your Command-Line Mission Control</h3>
      <p>
        An enterprise-grade, interactive framework for deep system diagnostics, performance monitoring, and security auditing. Built for SysAdmins, DevOps, and Security Professionals who demand clarity, control, and efficiency.
      </p>
    </td>
  </tr>
</table>

---

## 🚀 Key Features

SysInfoPro consolidates dozens of system checks into one powerful, intuitive interface.

<details>
<summary><strong>🖥️ System & OS Intelligence</strong></summary>
<ul>
    <li>Full OS, Distribution, and Kernel Details</li>
    <li>System Uptime, Load Average & Real-time Entropy</li>
    <li>Currently Logged-in Users & Last Login History</li>
    <li>Security Module Status (SELinux/AppArmor)</li>
    <li>World Clock for Major Timezones</li>
</ul>
</details>

<details>
<summary><strong>⚙️ Deep Hardware Analysis</strong></summary>
<ul>
    <li><strong>Pro GPU Monitoring</strong>: Auto-detects NVIDIA/AMD GPUs and uses native tools (<code>nvidia-smi</code>/<code>rocm-smi</code>) for detailed stats on temperature, fan speed, power draw, and VRAM usage.</li>
    <li>Detailed CPU Information (Model, Cores, Threads, Virtualization)</li>
    <li>Comprehensive Memory (RAM) and SWAP Usage</li>
    <li>Disk Filesystem Usage & Block Device Layout (<code>lsblk</code>)</li>
    <li><strong>S.M.A.R.T. Health Status</strong>: Proactively checks the health of all attached storage devices to predict failures.</li>
    <li>Motherboard & BIOS/UEFI Information (<code>dmidecode</code>)</li>
</ul>
</details>

<details>
<summary><strong>📦 Software & Process Management</strong></summary>
<ul>
    <li>Top Processes sorted by CPU and Memory usage</li>
    <li>Systemd Service Status (immediately highlights failed units)</li>
    <li>Installed Package Counts for major package managers (APT, DNF/YUM, Pacman)</li>
    <li>Container & Virtualization Detection (Docker, Podman, systemd-detect-virt)</li>
</ul>
</details>

<details>
<summary><strong>🌐 Advanced Network & Security Auditing</strong></summary>
<ul>
    <li>Full listing of Network Interfaces, IP Addresses, and Routing Tables</li>
    <li>List of all Listening TCP/UDP Ports and Active Connections</li>
    <li>DNS Configuration & Firewall Status (<code>ufw</code>, <code>firewalld</code>)</li>
    <li>On-demand Internet Speed Test</li>
    <li>Audit of recent failed login attempts and <code>sudo</code> command history</li>
    <li>On-demand Rootkit Scanning with <code>rkhunter</code></li>
</ul>
</details>

<details>
<summary><strong>📊 Interactive Live Dashboards</strong></summary>
<ul>
    <li><strong>Process Monitor</strong>: Live, interactive process list using <code>htop</code>.</li>
    <li><strong>Disk I/O Monitor</strong>: Real-time disk read/write activity with <code>iotop</code>.</li>
    <li><strong>Network Bandwidth Monitor</strong>: Live network traffic visualization with <code>bmon</code>.</li>
</ul>
</details>

<details>
<summary><strong>🚀 Core Framework Capabilities</strong></summary>
<ul>
    <li><strong>Data Export</strong>: Generate full system reports in <strong>JSON</strong> or <strong>HTML</strong> format for automation, auditing, and record-keeping.</li>
    <li><strong>Dependency Self-Check</strong>: A built-in tool to verify that all necessary helper utilities are installed.</li>
    <li><strong>Robust & Intuitive UI</strong>: A hierarchical menu system that is fast, clear, and prevents user error.</li>
    <li><strong>Root Privilege Awareness</strong>: The script warns if not run with <code>sudo</code>, explaining which features will be limited.</li>
</ul>
</details>

---

## 🛠️ Built With

SysInfoPro is a pure Bash script that intelligently integrates with the best-in-class command-line tools available on Linux.

<p align="center">
  <img src="https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=GNU%20Bash&logoColor=white" alt="GNU Bash">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=Linux&logoColor=black" alt="Linux">
</p>

**Key Integrations:** `lscpu`, `dmidecode`, `smartctl`, `nvidia-smi`, `htop`, `iotop`, `bmon`, `rkhunter`, `iproute2`, `systemd`, and more.

---

## 🔧 Getting Started

### Prerequisites

- A modern Linux distribution (Debian/Ubuntu, RHEL/Fedora, Arch, etc.)
- `git` for cloning the repository.

### Installation (One-Liner)

This single command clones the repository, enters the directory, and makes the core script executable.

```bash
git clone https://github.com/Opselon/SysInfoPro-Kali.git && \
cd SysInfoPro-Kali && \
chmod +x sysinfo.sh && \
sudo bash sysinfo.sh

