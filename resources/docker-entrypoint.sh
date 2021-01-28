#!/bin/sh

# Use gosu if the container started with root privileges
UID="$(id -u)"
[ "${UID}" -eq 0 ] && GOSU="gosu hedgedoc" || GOSU=""

if [ -n "${HMD_DB_URL}" ] && [ -z "${CMD_DB_URL}" ]; then
    CMD_DB_URL="${HMD_DB_URL}"
fi

if [ -n "${HMD_IMAGE_UPLOAD_TYPE}" ] && [ -z "${CMD_IMAGE_UPLOAD_TYPE}" ]; then
    CMD_IMAGE_UPLOAD_TYPE="${HMD_IMAGE_UPLOAD_TYPE}"
fi

DOCKER_SECRET_DB_URL_FILE_PATH="/run/secrets/dbURL"

if [ -f "${DOCKER_SECRET_DB_URL_FILE_PATH}" ]; then
    CMD_DB_URL="$(cat ${DOCKER_SECRET_DB_URL_FILE_PATH})"
fi

# configuration depends on choosen dialect
#
# see https://sequelize.org/master/class/lib/sequelize.js~Sequelize.html#instance-constructor-constructor
#
if [ -n "${CMD_DB_DIALECT}" ]; then
    if [ -z "${CMD_DB_HOST}" ]; then
        CMD_DB_HOST="database"
    fi
    if [ -z "${CMD_DB_PORT}" ]; then
        CMD_DB_PORT="5432"
    fi
    if [ -z "${CMD_DB_DATABASE}" ]; then
        CMD_DB_DATABASE="hedgedoc"
    fi
    if [ -z "${CMD_DB_USERNAME}" ]; then
        CMD_DB_USERNAME="hedgedoc"
    fi
    if [ -z "${CMD_DB_PASSWORD}" ]; then
        CMD_DB_PASSWORD="password"
    fi
    CMD_DB_URL="${CMD_DB_DIALECT}://${CMD_DB_USERNAME}:${CMD_DB_PASSWORD}@${CMD_DB_HOST}:${CMD_DB_PORT}/${CMD_DB_DATABASE}"
elif [ -z "${CMD_DB_URL}" ]; then
    CMD_DB_URL="postgres://hedgedoc:password@database:5432/hedgedoc"
fi

export CMD_DB_URL

DB_SOCKET=$(echo ${CMD_DB_URL} | sed -e 's/.*:\/\//\/\//' -e 's/.*\/\/[^@]*@//' -e 's/\/.*$//')

if [ "${DB_SOCKET}" != "" ]; then
    dockerize -wait "tcp://${DB_SOCKET}" -timeout 30s
fi

${GOSU} ./node_modules/.bin/sequelize db:migrate

# Print warning if local data storage is used but no volume is mounted
[ "${CMD_IMAGE_UPLOAD_TYPE}" = "filesystem" ] && { mountpoint -q ./public/uploads || {
    cat <<"EOF"
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
EOF
} ; }

# Change owner and permission if filesystem backend is used and user has root permissions
if [ "${UID}" -eq 0 ] && [ "${CMD_IMAGE_UPLOAD_TYPE}" = "filesystem" ]; then
    if [ "${UID}" -eq 0 ]; then
        chown -R hedgedoc ./public/uploads
        chmod 700 ./public/uploads
    else
        cat <<"EOF"
            #################################################################
            ###                                                           ###
            ###                        !!!WARNING!!!                      ###
            ###                                                           ###
            ###        Container was started without root permissions     ###
            ###           and filesystem storage is being used.           ###
            ###        In case of filesystem errors these need to be      ###
            ###                      changed manually                     ###
            ###                                                           ###
            ###                       !!!WARNING!!!                       ###
            ###                                                           ###
            #################################################################
EOF
    fi
fi

# Sleep to make sure everything is fine...
sleep 3

# run
exec ${GOSU} "$@"
