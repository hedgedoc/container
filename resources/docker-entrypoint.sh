#!/bin/sh

# Use gosu if the container started with root privileges
UID="$(id -u)"
[ "$UID" -eq 0 ] && GOSU="gosu hedgedoc" || GOSU=""

if [ "$HMD_IMAGE_UPLOAD_TYPE" != "" ] && [ "$CMD_IMAGE_UPLOAD_TYPE" = "" ]; then
    CMD_IMAGE_UPLOAD_TYPE="$HMD_IMAGE_UPLOAD_TYPE"
fi

# Print warning if local data storage is used but no volume is mounted
[ "$CMD_IMAGE_UPLOAD_TYPE" = "filesystem" ] && { mountpoint -q ./public/uploads || {
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

# Change owner and permission if filesystem backend is used and user has root permissions
if [ "$UID" -eq 0 ] && [ "$CMD_IMAGE_UPLOAD_TYPE" = "filesystem" ]; then
    if [ "$UID" -eq 0 ]; then
        echo "Updating uploads directory permissions ($UPLOADS_MODE)"
        chown -R hedgedoc ./public/uploads
        chmod $UPLOADS_MODE ./public/uploads
        find ./public/uploads -type f -executable -exec chmod a-x {} \;
    else
        echo "
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
        ";
    fi
fi

# Sleep to make sure everything is fine...
sleep 3

# run
exec $GOSU "$@"
