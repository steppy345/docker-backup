#!/bin/bash

# Define the backup directory
BACKUP_DIR="/backup/docker"

# Check if there are backup files in the backup directory
BACKUP_FILES=($BACKUP_DIR/docker_backup_*.tar.gz)

if [ ${#BACKUP_FILES[@]} -eq 0 ]; then
    echo "No backup files found in $BACKUP_DIR. Aborting restore process."
    exit 1
fi

# List all available backups
echo "Available backups:"
select BACKUP in "${BACKUP_FILES[@]}"; do
    if [ -n "$BACKUP" ]; then
        echo "You selected: $BACKUP"
        break
    else
        echo "Invalid selection. Please choose a number between 1 and ${#BACKUP_FILES[@]}."
    fi
done

# Stop all running containers before restoring
echo "Stopping all running Docker containers..."
RUNNING_CONTAINERS=$(docker ps -q)
if [ -n "$RUNNING_CONTAINERS" ]; then
    docker stop $RUNNING_CONTAINERS
else
    echo "No running Docker containers to stop."
fi

# Extract the selected backup tarball into /var/lib/
echo "Extracting backup: $BACKUP to /var/lib/"
sudo tar -xzf "$BACKUP" -C /var/lib/

# Check if /var/lib/docker has any data, and only start containers if data exists
if [ "$(ls -A /var/lib/docker)" ]; then
    echo "Starting all Docker containers..."
    docker start $(docker ps -aq)
else
    echo "No data in /var/lib/docker. No containers to start."
fi

echo "Restore process completed successfully."
