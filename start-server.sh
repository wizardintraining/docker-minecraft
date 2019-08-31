#!/bin/bash

function shutdown() {
  echo "Stopping Container..."
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

trap shutdown SIGINT

sleep infinity
