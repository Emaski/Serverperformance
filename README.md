# Server Performance Stats

It's a light Bash script to analyze and display basic performance metrics on any Linux server using standard built-in utilities.

## Features

- **System Information:** OS version, uptime, 1/5/15-minute load averages, logged-in users, and failed login attempts.
- **CPU Usage:** Total CPU usage percentage sampled over a 1-second interval.
- **Memory Usage:** Total, used, and free memory (MB and percentage).
- **Disk Usage:** Total, used, and free disk space across physical filesystems (excludes `tmpfs` and `devtmpfs`).
- **Top Processes:** Top 5 processes sorted by CPU usage and top 5 processes sorted by memory usage.

## Requirements

- Linux OS with `bash`
- Standard core utilities (`awk`, `df`, `free`, `ps`, `uptime`, `who`)
- `sudo` / root privileges (optional, required only to read failed login logs)
## Usage

1. **Clone or download the script:**
   ```bash
   git clone https://github.com/Emaski/Serverperformance.git
