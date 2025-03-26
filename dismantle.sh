#!/bin/bash

# Define the Docker data directory
DOCKER_DIR="/var/lib/docker"

# Confirmation prompt
read -p "WARNING: This will shut down all Docker containers and DELETE ALL Docker data. Are you sure? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Operation canceled."
    exit 1
fi

# Stop all running Docker containers
echo "Stopping all running Docker containers..."
docker stop $(docker ps -q)

# Delete all Docker data
echo "Deleting all Docker data in $DOCKER_DIR..."
sudo rm -rf "$DOCKER_DIR"/*

echo "Docker environment has been completely dismantled."
