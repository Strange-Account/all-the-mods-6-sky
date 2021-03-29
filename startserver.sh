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

if [ ! -f go-mc-server-starter ]; then
    URL="https://github.com/Strange-Account/go-mc-server-starter/releases/download/v0.0.1/go-mc-server-starter-v0.0.1-linux-386.tar.gz"
    echo "Downloading ${URL}"
    curl -s -L ${URL} | tar xvz
fi

echo "Starting serverstarter"
/opt/minecraft/serverdata/go-mc-server-starter

if [[ $DO_RAMDISK -eq 1 ]]; then
    echo "RAM disk configured. Restoring world folder ${SAVE_DIR}"
    sudo umount $SAVE_DIR
    rm -rf $SAVE_DIR
    mv "${SAVE_DIR}_backup" $SAVE_DIR
fi
