#!/bin/sh

if [ "$HMD_DB_URL" = "" ]; then
    HMD_DB_URL="postgres://hackmd:hackmdpass@hackmdPostgres:5432/hackmd"
fi

DB_SOCKET=$(echo ${HMD_DB_URL} | sed -e 's/.*:\/\//\/\//' -e 's/.*\/\/[^@]*@//' -e 's/\/.*$//')

if [ "$DB_SOCKET" != "" ]; then
    dockerize -wait tcp://${DB_SOCKET} -timeout 30s
fi

gosu hackmd node_modules/.bin/sequelize db:migrate

# Print warning if local data storage is used but no volume is mounted
[ "$HMD_IMAGE_UPLOAD_TYPE" = "filesystem" ] && { mountpoint -q ./public/uploads || {
    echo "
        #################################################################
        ###                                                           ###
        ###                        !!!WARNING!!!                      ###
        ###                                                           ###
        ###        Using local uploads without persistence is         ###
        ###            dangerous. You'll loose your data on           ###
        ###              container removal. Check out:                ###
        ###  https://docs.docker.com/engine/tutorials/dockervolumes/  ###
        ###                                                           ###
        ###                       !!!WARNING!!!                       ###
        ###                                                           ###
        #################################################################
    ";
} ; }

# Change owner and permission if filesystem backend is used
if [ "$HMD_IMAGE_UPLOAD_TYPE" = "filesystem" ]; then
    chown -R hackmd ./public/uploads
    chmod 700 ./public/uploads
fi

# Sleep to make sure everything is fine...
sleep 3

# run
exec gosu hackmd "$@"
