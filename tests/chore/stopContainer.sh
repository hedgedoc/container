#!/bin/sh
echo "
         ######################################
         ###       Stopping container       ###
         ######################################
"


# Make sure tests fails if a commend ends without 0
set -e

DOCKERCONTAINER=$(docker ps -qf name=hedgedoc)

docker ps -f id=${DOCKERCONTAINER}

# Clean up
docker stop ${DOCKERCONTAINER} && docker rm ${DOCKERCONTAINER}
