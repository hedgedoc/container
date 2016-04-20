#!/bin/dash

# wait for db up
sleep 3

# run
NODE_ENV='production' node app.js
