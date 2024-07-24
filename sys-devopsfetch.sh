#!/bin/bash

# Install necessary dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip
pip3 install tabulate

# Create the devopsfetch script
cat << 'EOF' > /usr/local/bin/devopsfetch.py
import argparse
import subprocess
from datetime import datetime
import os
try:
    from tabulate import tabulate
except ImportError:
    print("The 'tabulate' module is not installed. Please install it using 'pip3 install tabulate'.")
    exit(1)

def run_command(command):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

def get_active_ports(port=None):
    if port:
        command = f"ss -tuln | grep :{port}"
    else:
        command = "ss -tuln"
    return run_command(command)

def get_user_logins(user=None):
    if user:
        command = f"lastlog | grep {user}"
    else:
        command = "lastlog"
    return run_command(command)

def get_nginx_domains(domain=None):
    if domain:
        command = f"grep -r 'server_name {domain}' /etc/nginx/sites-available/"
    else:
        command = "grep -r 'server_name' /etc/nginx/sites-available/"
    return run_command(command)

def get_docker_info(container=None):
    if container:
        command = f"docker inspect {container}"
    else:
        command = "docker ps -a && docker images"
    return run_command(command)

def format_output(output):
    lines = output.split("\n")
    table = [line.split() for line in lines]
    return tabulate(table, headers="firstrow", tablefmt="grid")

def main():
    parser = argparse.ArgumentParser(description="DevOpsFetch - A tool for DevOps information retrieval and monitoring")
    parser.add_argument('-p', '--port', nargs='?', const=True, help='Display active ports and services')
    parser.add_argument('-d', '--docker', nargs='?', const=True, help='List Docker images and containers')
    parser.add_argument('-n', '--nginx', nargs='?', const=True, help='Display Nginx domains and their ports')
    parser.add_argument('-u', '--users', nargs='?', const=True, help='List users and their last login times')
    parser.add_argument('-t', '--time', help='Display activities within a specified time range')
    parser.add_argument('-h', '--help', action='help', help='Show this help message and exit')
    parser.add_argument('-m', '--monitor', action='store_true', help='Run in continuous monitoring mode')

    args = parser.parse_args()

    if args.monitor:
        log_file = "/var/log/devopsfetch.log"
        while True:
            with open(log_file, "a") as f:
                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                f.write(f"\n--- Log at {timestamp} ---\n")
                f.write(get_active_ports() + "\n")
                f.write(get_user_logins() + "\n")
                f.write(get_nginx_domains() + "\n")
                f.write(get_docker_info() + "\n")
                f.flush()
            time.sleep(60)  # Log every minute
    else:
        if args.port is not None:
            if args.port is True:
                output = get_active_ports()
            else:
                output = get_active_ports(args.port)
            print(format_output(output))
        elif args.docker is not None:
            if args.docker is True:
                output = get_docker_info()
            else:
                output = get_docker_info(args.docker)
            print(format_output(output))
        elif args.nginx is not None:
            if args.nginx is True:
                output = get_nginx_domains()
            else:
                output = get_nginx_domains(args.nginx)
            print(format_output(output))
        elif args.users is not None:
            if args.users is True:
                output = get_user_logins()
            else:
                output = get_user_logins(args.users)
            print(format_output(output))
        elif args.time:
            # Implement time range filtering logic here
            pass
        else:
            parser.print_help()

if __name__ == "__main__":
    main()
EOF

# Make the script executable
chmod +x /usr/local/bin/devopsfetch.py

# Create systemd service
echo "Creating systemd service..."
cat << 'EOF' | sudo tee /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOpsFetch Service

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/devopsfetch.py --monitor
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
echo "Setting up the service..."
sudo systemctl daemon-reload
sudo systemctl enable devopsfetch.service
sudo systemctl start devopsfetch.service

# Set up log rotation
LOG_FILE="/var/log/devopsfetch.log"
echo "Setting up log rotation..."
cat << 'EOF' | sudo tee -a "$LOG_FILE"
/var/log/devopsfetch.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        systemctl restart devopsfetch.service > /dev/null
    endscript
}
EOF

echo "Installation and setup complete."
