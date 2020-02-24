#!/bin/bash

function shutdown() {
  echo "Stopping Minecraft..."
  tmux send-keys -t Minecraft "say §cServer Shutting Down\015"
  tmux send-keys -t Minecraft "save-all\015"
  sleep 3
  tmux send-keys -t Minecraft "stop\015"
  echo "Stopping container."
  exit
}

echo "Starting Container..."

# Create server folder if it does not exist
if [ ! -d ${SERVER_DIR} ]; then
  mkdir ${SERVER_DIR}
fi

# So called Modpack support
if [ "${LOAD_MODPACK}" == "true" ]; then
  if [ "${JAR_NAME}" == "vanilla" ]; then
    echo "forge jar not found, please check JAR_NAME variable."
    sleep infinity
    exit
  fi
  if [ ! -f $SERVER_DIR/${JAR_NAME}.jar ]; then
    if [ ! -d ${MOD_SOURCE} ]; then
      echo "modpack sources not found, please check JAR_NAME variable."
      sleep infinity
      exit
    fi
    if [ ! -f ${MOD_SOURCE}/${JAR_NAME}.jar ]; then
      echo "forge jar not found, please check mod_sorce folder for matching name (${JAR_NAME}.jar)."
      sleep infinity
      exit
    fi
    cp -rT ${MOD_SOURCE} ${SERVER_DIR}
  fi
fi

# Download vanilla Minecraft server if the designated .jar is not found
if [ ! -f $SERVER_DIR/${JAR_NAME}.jar ] && [ "${JAR_NAME}" == "vanilla" ]; then
  echo "Downloading Minecraft Server 1.15.2 ..."
  wget -q 'https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar' -O ${SERVER_DIR}/${JAR_NAME}.jar
  if [ ! -f $SERVER_DIR/${JAR_NAME}.jar ]; then
    echo "Error downloading server jar file."
    sleep infinity
    exit
  else
    echo "Download Complete"
  fi
fi

# Download default server.properties file if one is not found
if [ ! -f ${SERVER_DIR}/server.properties ]; then
  echo "Copying default server.properties file..."
  cp /opt/serverproperties.default ${SERVER_DIR}/server.properties 
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
  echo "0 */${BACKUP_INTERVAL} * * * /root/project_env.sh; /opt/backup.sh" | crontab -
  /etc/init.d/cron start > /dev/null
else
  echo "Backups: DISABLED"
fi

chmod 777 -R ${SERVER_DIR}

# Signal Traps for graceful Minecraft shutdown
# on callback, kill the last background process, which is `tail -F ${SERVER_DIR}/logs/latest.log` and execute the specified handler
trap 'kill ${!}; shutdown' SIGTERM
trap 'kill ${!}; shutdown' SIGINT

# Start the server via tmux
echo "Starting Server..."
cd ${SERVER_DIR}
tmux new-session -d -n Minecraft java -Xms${XMS_SIZE}M -Xmx${XMX_SIZE}M ${OPT_PARAMS} -jar ${JAR_NAME}.jar nogui
sleep 5
echo "logging wait ..."
# Logs
# Wait until the log file exists
while [ ! -f ${SERVER_DIR}/logs/latest.log ];
do
  sleep 2
done

# tail the log file for docker
tail -F ${SERVER_DIR}/logs/latest.log & wait ${!}

