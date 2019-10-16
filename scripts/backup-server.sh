#!/bin/bash

# Import the ENV variables
scriptPath=$(dirname "$(readlink -f "$0")")
source "${scriptPath}/.env.sh"

# Notify players that a backup is starting
screen -R Minecraft -X stuff "say §dBackup starting...\015"

# Turn off auto-saving and do a manual save
screen -R Minecraft -X stuff "save-off\015"
screen -R Minecraft -X stuff "save-all\015"
sleep 3

# Create backups folder if it does not exist
if [ ! -d ${BACKUP_DIR} ]; then
  mkdir ${BACKUP_DIR}
fi

# Create a backup
_now=$(date +"%m_%d_%Y_%T")
_file="${BACKUP_DIR}/${_now}"

cd ${SERVER_DIR}
zip -r --exclude=backups/* --exclude=dynmap/* ${_file} *

# Delete old backups past the retention amout
cd ${BACKUP_DIR}
ls -t | sed -e "1,${BACKUP_RETENTION}d" | xargs -d '\n' rm

# Notify players that the backup has completed
screen -R Minecraft -X stuff "save-on\015"
screen -R Minecraft -X stuff "say §dBackup complete.\015"
