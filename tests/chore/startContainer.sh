#!/bin/sh
echo "
         ######################################
         ###       Starting container       ###
         ######################################
"


# Make sure tests fails if a commend ends without 0
set -e

# Generate some random ports for testing
PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=10000 -v r=19999 '{printf "%i\n", f + r * $1 / 65536}')

# Make sure the ports are not already in use. In case they are rerun the script to get new ports.
[ $(netstat -an | grep LISTEN | grep :$PORT | wc -l) -eq 0 ] || { ./$0 && exit 0 || exit 1; }

# Run container in a simple way
docker ps -f id=$(docker run -d --name codimd-testing --network postgres -p 127.0.0.1:${PORt}:3000 -e "HMD_DB_URL=postgres://hackmd:hackmdpass@hackmdPostgres:5432/hackmd" codimd:testing)
