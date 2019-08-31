FROM openjdk:8u222

RUN mkdir /data

COPY ./start-server.sh /data/start-server.sh

ENTRYPOINT ["/data/start-server.sh"]
