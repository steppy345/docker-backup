# Docker Backup Scripts

Prerequisites: 
- Run in root user context of docker host.

## perform-backup.sh
- Backs up /var/lib/docker to /backup/docker/ on docker host

## dismantle.sh
- Destroys all data in /var/lib/docker/
- Used for testing backup and restore

## restore-backup.sh
- Prompts user and restores backup from /backup/docker/ to /var/lib/
