FROM registry.access.redhat.com/ubi8/ubi-minimal:8.3

ARG JAVA_PACKAGE=java-1.8.0-openjdk-headless
ARG RPM_BASE='http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/'

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'

# download tmux package
# Install java and tmux
RUN curl -s ${RPM_BASE} > /pkglist && \
    curl -s --output /tmux.rpm \
        ${RPM_BASE}"$(grep tmux /pkglist |grep --o 'tmux-.[^"<>]*.rpm'|head -1)" && \
    microdnf install --nodocs openssl curl ca-certificates ${JAVA_PACKAGE} \
        libevent zip cronie && \
    rpm -i --excludedocs /tmux.rpm && \
    microdnf update && \
    microdnf clean all && \
    rm -rf /var/cache/yum /pkglist /tmux.rpm

# set up permissions for user `1001`
RUN mkdir -p  /opt && \
    chown 1001:root /opt && \
    chmod 2775 /opt && \
    mkdir -p  /data && \
    chown 1001:root /data && \
    chmod 2775 /data

# Configure the run options
ENV SERVER_DIR="/data" \
    BACKUP_DIR="/data/backups" \
    JAR_NAME="vanilla" \
    JAVA_OPTIONS="-XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions \
      -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M" \
    ACCEPT_EULA="false" \
    XMS_SIZE="1024" \
    XMX_SIZE="1024" \
    LOAD_MODPACK="false" \
    MOD_SOURCE="/mod_source" \
    BACKUP_ENABLED="false" \
    BACKUP_INTERVAL="2" \
    BACKUP_RETENTION="10"


EXPOSE 25565
USER 1001
COPY scripts/ /opt/

ENTRYPOINT ["/opt/serverstart.sh"]

