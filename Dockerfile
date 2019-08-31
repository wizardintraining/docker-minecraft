FROM openjdk:8u222

ENV DATA_DIR="/data" \
    UID="99" \
    GID="100"

RUN mkdir $DATA_DIR

RUN useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID minecraft && \
    chown -R minecraft $DATA_DIR

COPY ./start-server.sh /opt/start-server.sh

USER minecraft

ENTRYPOINT ["/opt/start-server.sh"]
