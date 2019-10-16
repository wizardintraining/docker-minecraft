#!/bin/bash

function shutdown() {
  echo "Stopping Minecraft..."
  screen -R Minecraft -X stuff "say §cServer Shutting Down\015"
  screen -R Minecraft -X stuff "save-all\015"
  sleep 3
  screen -R Minecraft -X stuff "stop\015"
  echo "Stopping container."
  exit
}

echo "Starting Container..."

# Create server folder if it does not exist
if [ ! -d ${SERVER_DIR} ]; then
  mkdir ${SERVER_DIR}
fi

# Download vanilla Minecraft server if the designated .jar is not found
if [ ! -f $SERVER_DIR/${JAR_NAME}.jar ]; then
  if [ "${JAR_NAME}" != "server" ]; then
    echo "Custom jar not found, please check JAR_NAME variable."
    sleep infinity
    exit
  fi
  cd ${SERVER_DIR}
  echo "Downloading Minecraft Server 1.14.4..."
  wget -qi ${JAR_NAME} https://launcher.mojang.com/v1/objects/3dc3d84a581f14691199cf6831b71ed1296a9fdf/server.jar
  if [ ! -f $SERVER_DIR/${JAR_NAME}.jar ]; then
    echo "Error downloading server.jar file."
    sleep infinity
    exit
  else
    echo "Download Complete"
  fi
fi

# Download default server.properties file if one is not found
if [ ! -f ${SERVER_DIR}/server.properties ]; then
  echo "Downloading default server.properties file..."
  wget -qi ${SERVER_DIR}/server.properties https://raw.githubusercontent.com/dbkynd/docker-minecraft/master/server.properties
  if [ ! -f ${SERVER_DIR}/server.properties ]; then
    echo "Error downloading server.properties file."
    sleep infinity
    exit
  else
    echo "Download Complete"
  fi
fi

# Validate the ACCEPT_EULA variable
if [ "${ACCEPT_EULA}" != "true" ] && [ "${ACCEPT_EULA}" != "false" ]; then
  echo "Something went wrong, please check the ACCEPT_EULA variable."
  sleep infinity
  exit
fi

# Create the EULA file if it does not exist with the defined value
if [ ! -f $SERVER_DIR/eula.txt ]; then
  echo "eula=${ACCEPT_EULA}" >> ${SERVER_DIR}/eula.txt
fi

# Halt if the ACCEPT_EULA value is false
if [ "${ACCEPT_EULA}" == "false" ]; then
  # Alter the eula.txt file if previoulsy true
  if grep -rq 'eula=true' ${SERVER_DIR}/eula.txt; then
    sed -i '/eula=true/c\eula=false' ${SERVER_DIR}/eula.txt
  fi
  echo "You must accept the EULA to start the server."
  sleep infinity
  exit
elif [ "${ACCEPT_EULA}" == "true" ]; then
  # Alter the eula.txt file if previoulsy false
  if grep -rq 'eula=false' ${SERVER_DIR}/eula.txt; then
    sed -i '/eula=false/c\eula=true' ${SERVER_DIR}/eula.txt
  fi
fi

# Validate the BACKUP_ENABLED variable
if [ "${BACKUP_ENABLED}" != "true" ] && [ "${BACKUP_ENABLED}" != "false" ]; then
  echo "Something went wrong, please check the BACKUP_ENABLED variable."
  sleep infinity
  exit
fi

if [ "${BACKUP_ENABLED}" == "true" ]; then
  echo "Backups: ENABLED - Interval: ${BACKUP_INTERVAL}hrs - Retention: ${BACKUP_RETENTION}"
  # Export the ENV variables for crontab
  scriptPath=$(dirname "$(readlink -f "$0")")
  printenv | sed 's/^\(.*\)$/export \1/g' > ${scriptPath}/.env.sh
  chmod +x ${scriptPath}/.env.sh
  # Create the cron entry and start cron
  echo "*/${BACKUP_INTERVAL} * * * * /root/project_env.sh; /opt/backup-server.sh" | crontab -
  /etc/init.d/cron start > /dev/null
else
  echo "Backups: DISABLED"
fi

chmod 777 -R ${SERVER_DIR}

# Signal Traps for graceful Minecraft shutdown
# on callback, kill the last background process, which is `tail -F ${SERVER_DIR}/logs/latest.log` and execute the specified handler
trap 'kill ${!}; shutdown' SIGTERM
trap 'kill ${!}; shutdown' SIGINT

# Start the server via screen
echo "Starting Server..."
cd ${SERVER_DIR}
screen -DmS Minecraft java -Xms${XMS_SIZE}M -Xmx${XMX_SIZE}M ${OPT_PARAMS} -jar ${SERVER_DIR}/${JAR_NAME}.jar nogui &
sleep 5

# Logs
# Wait until the log file exists
while [ ! -f ${SERVER_DIR}/logs/latest.log ];
do
  sleep 2
done

# tail the log file for docker
tail -F ${SERVER_DIR}/logs/latest.log & wait ${!}
