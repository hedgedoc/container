#!/bin/dash


sleep 10

# setting databse
createdb -h db-postgres -U $POSTGRES_USER -O hackmd hackmd
psql -h db-postgres -U $POSTGRES_USER hackmd < ./hackmd_schema.sql 

# run
nodejs app.js
