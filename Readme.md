## Requirements:
Information Retrieval:
1. Ports:
   - Display all active ports and services `(-p or --port)`.
   - Provide detailed information about a specific port `(-p <port_number>)`.
2. Docker:
   - List all Docker images and containers `(-d or --docker)`.
   - Provide detailed information about a specific container `(-d <container_name>)`.
3. Nginx:
   - Display all Nginx domains and their ports `(-n or --nginx)`.
   - Provide detailed configuration information for a specific domain `(-n <domain>)`.
4. Users:
   - List all users and their last login times `(-u or --users)`.
   - Provide detailed information about a specific user `(-u <username>`).
5. Time Range:
   - Display activities within a specified time range `(-t or --time)`.

## Usage
Save the script to a file, e.g., devopsfetch.sh.
Make the script executable by running: chmod +x devopsfetch.sh.
Execute the script with the desired options:
To display all active ports: ./devopsfetch.sh -p
To display information about a specific port: ./devopsfetch.sh -p 80
To list Docker images and containers: ./devopsfetch.sh -d
To display information about a specific Docker container: ./devopsfetch.sh -d container_name
To display all Nginx domains and their ports: ./devopsfetch.sh -n
To display configuration for a specific Nginx domain: ./devopsfetch.sh -n domain.com
To list all users and their last login times: ./devopsfetch.sh -u
To display information about a specific user: ./devopsfetch.sh -u username
To display activities within a time range: ./devopsfetch.sh -t "2024-07-23 00:00:00" "2024-07-23 23:59:59"

# systemd

## Explanation of the Installation Script

Install Dependencies: Updates the package list and installs python3, python3-pip, and the tabulate module.

Create Script: Writes the devopsfetch.py script to /usr/local/bin/ and makes it executable.

Create Systemd Service: Sets up a systemd service to run the devopsfetch.py script in continuous monitoring mode.

Enable and Start Service: Reloads systemd, enables the new service, and starts it.

Log Rotation: Configures log rotation to manage the log file at /var/log/devopsfetch.log

## Commands
```
sudo bash sys-devopsfetch.sh
sudo systemctl status devopsfetch.service
```