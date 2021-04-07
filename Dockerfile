#FROM adoptopenjdk/openjdk8-openj9:alpine-jre
FROM openjdk:8-jre-alpine

# Needed by our code
RUN apk --update upgrade && \
    apk add bash curl htop tini && \
    apk add --no-cache python3 py3-pip icu-libs shadow && \
    pip3 install watchdog && \
    wget https://raw.githubusercontent.com/phusion/baseimage-docker/9f998e1a09bdcb228af03595092dbc462f1062d0/image/bin/setuser -O /sbin/setuser && \
    chmod +x /sbin/setuser && \
    rm -rf /var/cache/apk/*

RUN wget -O /usr/local/bin/runas.sh \
  'https://raw.githubusercontent.com/coppit/docker-inotify-command/dd981dc799362d47387da584e1a276bbd1f1bd1b/runas.sh'
RUN chmod +x /usr/local/bin/runas.sh

RUN mkdir -p /opt/minecraft/serverdata

ADD startserver.sh /opt/minecraft/startserver.sh
RUN chmod a+x /opt/minecraft/startserver.sh

ADD server-setup-config.yaml /opt/minecraft/server-setup-config.yaml

WORKDIR /opt/minecraft/serverdata

# Run as root by default
ENV USER_ID 0
ENV GROUP_ID 0
ENV UMASK 0000

ENTRYPOINT ["tini", "--"]
CMD /usr/local/bin/runas.sh "$USER_ID" "$GROUP_ID" "$UMASK" /opt/minecraft/startserver.sh