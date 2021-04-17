#!/bin/sh
echo "
         ######################################
         ###       Starting container       ###
         ######################################
"


# Make sure tests fails if a commend ends without 0
set -e

# Generate some random ports for testing
PORT=$(( $(shuf -e $(seq 0 9999) | head -n1) + 10000 ))

# Make sure the ports are not already in use. In case they are rerun the script to get new ports.
[ $(netstat -l4n | grep LISTEN | grep :$PORT | wc -l) -eq 0 ] || { ./$0 && exit 0 || exit 1; }

# Run container in a simple way
docker ps -f id=$(docker run -d --name hedgedoc --network postgres -p 127.0.0.1:${PORT}:3000 -e "CMD_DB_URL=postgres://hedgedoc:password@database:5432/hedgedoc" hedgedoc)

sleep 30
