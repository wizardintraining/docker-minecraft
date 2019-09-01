FROM openjdk:8u222

RUN apt-get update && \
    apt-get install -y wget screen

ENV DATA_DIR="/data" \
    SERVER_DIR="/data/server" \
    JAR_NAME="server" \
    OPT_PARAMS="" \
    ACCEPT_EULA="false" \
    XMS_SIZE="1024" \
    XMX_SIZE="1024" \
    UID="500" \
    GID="100"

RUN mkdir $DATA_DIR

RUN useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID minecraft && \
    chown -R minecraft $DATA_DIR

COPY ./start-server.sh /opt/start-server.sh

RUN chmod 770 /opt/start-server.sh && \
    chown minecraft /opt/start-server.sh

USER minecraft

ENTRYPOINT ["/opt/start-server.sh"]
