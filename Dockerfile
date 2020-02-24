FROM docker.io/adoptopenjdk/openjdk8:ubi-jre

RUN \
 dnf update -y && \
 dnf install --nodocs -y \
   libevent \
   cronie \
   wget \
   zip && \
 wget 'http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/' -O pkglist && \
 wget -O tmux.rpm \
  'http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/'\
"$(grep tmux pkglist |grep --o 'tmux-.[^"<>]*.rpm'|head -1)" && \
 dnf install --nodocs -y ./tmux.rpm && \
 dnf clean all && \
 rm -rf /var/cache/yum pkglist tmux.rpm

RUN touch /etc/crontab /etc/cron.*/*

ENV SERVER_DIR="/data" \
    BACKUP_DIR="/data/backups" \
    JAR_NAME="vanilla" \
    OPT_PARAMS="-XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M" \
    ACCEPT_EULA="false" \
    XMS_SIZE="1024" \
    XMX_SIZE="1024" \
    LOAD_MODPACK="false" \
    MOD_SOURCE="/mod_source" \
    BACKUP_ENABLED="false" \
    BACKUP_INTERVAL="2" \
    BACKUP_RETENTION="10"
EXPOSE 25565

COPY scripts/ /opt/

RUN chmod 770 -R /opt

ENTRYPOINT ["/opt/serverstart.sh"]
