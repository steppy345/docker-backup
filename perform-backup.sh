#!/bin/bash

# Define the backup directory
BACKUP_DIR="/backup/docker"

# Number of backup copies to keep (set this as needed)
MAX_BACKUPS=5

# Check if /var/lib/docker has data before performing the backup
if [ ! "$(ls -A /var/lib/docker)" ]; then
    echo "No data found in /var/lib/docker. Aborting backup process."
    exit 1
fi

# Check if the backup directory exists; if not, create it
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory $BACKUP_DIR does not exist. Creating it..."
    sudo mkdir -p "$BACKUP_DIR"
else
    echo "Backup directory $BACKUP_DIR already exists. Proceeding with backup..."
fi

# Generate a timestamp for the backup filename (YYYY-MM-DD_HH-MM-SS)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Define the backup file name with the timestamp
BACKUP_FILE="$BACKUP_DIR/docker_backup_${TIMESTAMP}.tar.gz"

# Check if there are running Docker containers
RUNNING_CONTAINERS=$(docker ps -q)

# Stop all Docker containers if there are any running
if [ -n "$RUNNING_CONTAINERS" ]; then
    echo "Stopping all Docker containers..."
    docker stop $RUNNING_CONTAINERS
else
    echo "No running Docker containers found. Skipping stop operation."
fi

# Create a compressed tarball of /var/lib/docker with progress indication using pv
echo "Creating backup tarball: $BACKUP_FILE"
sudo tar -czf - /var/lib/docker | pv -s $(du -sb /var/lib/docker | awk '{print $1}') > "$BACKUP_FILE"

# Start the containers back up
echo "Starting all Docker containers..."
docker start $(docker ps -aq)

# Clean up old backups if the total number of backups exceeds the limit
BACKUP_COUNT=$(ls -1 $BACKUP_DIR/docker_backup_*.tar.gz | wc -l)

if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
    echo "More than $MAX_BACKUPS backups exist. Deleting the oldest backups..."

    # List backups sorted by modification time (oldest first) and delete the excess ones
    ls -1t $BACKUP_DIR/docker_backup_*.tar.gz | tail -n +$(($MAX_BACKUPS + 1)) | while read OLD_BACKUP; do
        echo "Deleting old backup: $OLD_BACKUP"
        rm -f "$OLD_BACKUP"
    done

    echo "Old backups deleted. Keeping only the $MAX_BACKUPS most recent backups."
else
    echo "Backup count ($BACKUP_COUNT) is within the limit of $MAX_BACKUPS. No backups to delete."
fi

echo "Backup process completed successfully."
