#!/bin/sh
echo "
         ######################################
         ###         New note test          ###
         ######################################
"


# Make sure tests fails if a commend ends without 0
set -e

wget -O- http://127.0.0.1:${PORT}/new

docker logs ${DOCKERCONTAINER}
