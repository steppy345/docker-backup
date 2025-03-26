# Docker Backup Scripts

Prerequisites: 
- Run in root user context of docker host.

## 1. perform-backup.sh
- Backs up /var/lib/docker to /backup/docker/ on docker host
- Default number of backups is 5.  Edit file to modify
- Creates cronjob backup for 2 a.m. daily

## (Optional) dismantle.sh
- Destroys all data in /var/lib/docker/
- Used for testing backup and restore

## 2. restore-backup.sh
- Prompts user and restores backup from /backup/docker/ to /var/lib/
