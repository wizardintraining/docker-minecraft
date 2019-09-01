FROM openjdk:8u222

RUN apt-get update && \
    apt-get install -y wget

ENV DATA_DIR="/data" \
    SERVER_DIR="/data/server" \
    JAR_NAME="server" \
    ACCEPT_EULA="false" \
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
