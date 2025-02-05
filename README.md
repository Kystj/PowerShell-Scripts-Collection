# PowerShell Scripts Collection

This repository contains a collection of useful and versatile PowerShell scripts designed for system administration, automation, performance monitoring, and various Windows-based tasks. These scripts are designed to save time, automate repetitive tasks, and streamline various processes for system administrators, developers, and tech enthusiasts.

## Overview

This collection includes a variety of PowerShell scripts for different use cases such as:

- **System Monitoring**: Monitor CPU usage, memory, disk space, and overall system health.
- **Automation**: Automate workflows, scheduling tasks, and triggering actions.
- **Configuration Management**: Manage system configurations, network settings, software installations, and updates.
- **General Utilities**: Perform actions such as cleaning up old files, managing backups, and running diagnostics.

Each script is independent and intended to perform specific tasks. You can choose and run only the scripts that meet your needs.

## Table of Contents
- [CPU Performance Monitoring Script](#cpu-performance-monitoring-script)
- [System Health Check and Report Generator](#system-health-check-and-report-generator)
- [Integrity Watcher](#integrity-watcher)

---

# CPU Performance Monitoring Script

### Overview

This PowerShell script automates the monitoring of CPU usage on your Windows system. When scheduled via Windows Task Scheduler, it checks the system’s CPU usage and logs the data, including an alert if the usage exceeds a defined threshold. The script also plays an audible beep and logs the process with the highest CPU usage when the threshold is surpassed.

### Features

- Logs CPU usage and timestamp.
- Checks if CPU usage exceeds a predefined threshold.
- Alerts when usage goes above the threshold:
  - Logs a message indicating the high CPU usage.
  - Plays a beep sound to notify the user.
  - Logs the process consuming the most CPU.
- Option for balloon notifications (commented out by default).
- Saves logs to a configurable location for later analysis.

### Requirements

- PowerShell 7 (or later) installed on Windows.
- Windows Task Scheduler to run the script at specific intervals.
- Edit the script's configuration to specify the CPU threshold and log location.

### Usage Instructions

1. **Configure the Script**  
   - Adjust the `$threshold` variable to set your preferred CPU usage threshold (e.g., `25` for 25%).
   - Edit the `$logFile` variable to specify where you want to save the log file (ensure the path exists or create it).

2. **Schedule the Script with Windows Task Scheduler**  
   - Set up Task Scheduler to run this script at regular intervals.
   - Make sure the task is configured to run under a user that has permissions to execute the script and write to the log directory.

3. **Script Behavior**  
   The script will automatically check CPU usage. If usage exceeds the threshold, it will alert you by:
   - Writing an alert message to the log file.
   - Playing a short beep sound.
   - Logging the process that uses the highest CPU.
   - OPTIONALLY: Notify via a popup window.

### Example Log Output

```txt
2025-01-13 09:30:15: CPU usage is at 40%
2025-01-13 09:30:15: ALERT! CPU usage is at 40%, which is above the threshold.
2025-01-13 09:30:15: Process with the highest CPU usage: chrome
```
---

# System Health Check and Report Generator

This PowerShell script gathers basic system health metrics, logs them, and generates a simple HTML report. It’s useful for checking the status of your system in terms of CPU usage, memory, disk space, and uptime.

## Features
- **Logging**: Logs each step of the script execution and any errors to a specified log file.
- **HTML Report**: Generates an HTML report showing system health metrics like CPU usage, memory usage, disk space, and uptime.
- **Directory Creation**: Automatically creates necessary directories for logs and reports if they don’t already exist.

## Configuration

Before running the script, customize the following variables to specify your preferred file paths:

```powershell
$reportPath = "<Enter_Your_Report_File_Path>"
$logFile = "<Enter_Your_Log_File_Path>"
```
---

# Integrity Watcher

