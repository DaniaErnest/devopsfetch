#!/bin/bash

# Function to display help
display_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -p, --port [PORT]         Display all active ports and services, or detailed information about a specific port"
    echo "  -d, --docker [CONTAINER]  List all Docker images and containers, or detailed information about a specific container"
    echo "  -n, --nginx [DOMAIN]      Display all Nginx domains and their ports, or detailed configuration information for a specific domain"
    echo "  -u, --users [USERNAME]    List all users and their last login times, or detailed information about a specific user"
    echo "  -t, --time START END      Display activities within a specified time range (format: YYYY-MM-DD HH:MM:SS)"
    echo "  -h, --help                Display this help message"
    exit 1
}

# Function to display active ports
display_ports() {
    if [ -z "$1" ]; then
        echo "Active Ports and Services:"
        sudo netstat -tuln
    else
        echo "Detailed information about port $1:"
        sudo netstat -tulnp | grep ":$1 "
    fi
}

# Function to display Docker information
display_docker() {
    if [ -z "$1" ]; then
        echo "Docker Images:"
        sudo docker images
        echo "Docker Containers:"
        sudo docker ps -a
    else
        echo "Detailed information about container $1:"
        sudo docker inspect "$1"
    fi
}

# Function to display Nginx information
display_nginx() {
    if [ -z "$1" ]; then
        echo "Nginx Domains and their Ports:"
        sudo grep -r 'listen' /etc/nginx/
    else
        echo "Detailed configuration for domain $1:"
        sudo grep -r 'server_name' /etc/nginx/
    fi
}

# Function to display user information
display_users() {
    if [ -z "$1" ]; then
        echo "All users and their last login times:"
        lastlog
    else
        echo "Detailed information about user $1:"
        last "$1"
    fi
}

# Function to display activities within a specified time range
display_time_range() {
    echo "Displaying activities from $1 to $2:"
    sudo journalctl --since="$1" --until="$2"
}

# Check command-line arguments
if [ $# -eq 0 ]; then
    display_help
fi

# Handle command-line arguments
case "$1" in
    -p|--port)
        if [ -n "$2" ]; then
            display_ports "$2"
        else
            display_ports
        fi
        ;;
    -d|--docker)
        if [ -n "$2" ]; then
            display_docker "$2"
        else
            display_docker
        fi
        ;;
    -n|--nginx)
        if [ -n "$2" ]; then
            display_nginx "$2"
        else
            display_nginx
        fi
        ;;
    -u|--users)
        if [ -n "$2" ]; then
            display_users "$2"
        else
            display_users
        fi
        ;;
    -t|--time)
        if [ -n "$2" ] && [ -n "$3" ]; then
            display_time_range "$2" "$3"
        else
            echo "Error: --time option requires a start and end time"
            display_help
        fi
        ;;
    -h|--help)
        display_help
        ;;
    *)
        echo "Unknown option: $1"
        display_help
        ;;
esac
