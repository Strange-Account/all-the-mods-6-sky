#!/bin/bash
DO_RAMDISK=0
if [ ! -f server-setup-config.yaml ]; then
    echo "No server-setup-config.yaml - copying from image"
    cp /opt/minecraft/server-setup-config.yaml /opt/minecraft/serverdata/
fi

if [[ $(cat server-setup-config.yaml | grep 'ramDisk:' | awk 'BEGIN {FS=":"}{print $2}') =~ "yes" ]]; then
    SAVE_DIR=$(cat server.properties | grep 'level-name' | awk 'BEGIN {FS="="}{print $2}')
    echo "RAM disk configured. Creating backup of world folder ${SAVE_DIR}"
    mv $SAVE_DIR "${SAVE_DIR}_backup"
    mkdir $SAVE_DIR
    sudo mount -t tmpfs -o size=2G tmpfs $SAVE_DIR
    DO_RAMDISK=1
fi

if [ ! -f serverstarter-1.2.7.jar ]; then
    URL="https://github.com/BloodyMods/ServerStarter/releases/download/v1.2.7/serverstarter-1.2.7.jar"
    echo "Downloading ${URL}"
    wget -O serverstarter-1.2.7.jar "${URL}"
fi

echo "Starting serverstarter"
java -d64 -jar serverstarter-1.2.7.jar

if [[ $DO_RAMDISK -eq 1 ]]; then
    echo "RAM disk configured. Restoring world folder ${SAVE_DIR}"
    sudo umount $SAVE_DIR
    rm -rf $SAVE_DIR
    mv "${SAVE_DIR}_backup" $SAVE_DIR
fi
