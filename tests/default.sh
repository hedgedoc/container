#!/bin/sh
echo "
         ######################################
         ###          Default test          ###
         ######################################
"


# Make sure tests fails if a commend ends without 0
set -e

DOCKERCONTAINER=$(docker ps -qf name=hedgedoc)
PORT=$(echo $(docker port $DOCKERCONTAINER) | cut -d: -f2)

wget -O- http://127.0.0.1:${PORT}/

docker logs ${DOCKERCONTAINER}
