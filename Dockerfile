FROM openjdk:8u222

RUN apt-get update && \
    apt-get install -y \
    cron \
    screen \
    wget \
    zip

ENV SERVER_DIR="/data" \
    BACKUP_DIR="/data/backups" \
    JAR_NAME="server" \
    OPT_PARAMS="" \
    ACCEPT_EULA="false" \
    XMS_SIZE="1024" \
    XMX_SIZE="1024" \
    BACKUP_ENABLED="false" \
    BACKUP_INTERVAL="2" \
    BACKUP_RETENTION="10"

COPY scripts/ /opt/

RUN chmod 770 -R /opt

RUN touch /etc/crontab /etc/cron.*/*

ENTRYPOINT ["/opt/start-server.sh"]
