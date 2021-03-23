FROM openjdk:8u282-jre
COPY . /opt/minecraft
RUN mkdir /opt/minecraft/serverdata
WORKDIR /opt/minecraft/serverdata
CMD ["/opt/minecraft/startserver.sh"]