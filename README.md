docker-hackmd
===

## Require
* docker (docker toolbox recommended)
* docker-compose

See more here: https://www.docker.com/docker-toolbox


## Usage

Start your docker and enter the terminal, follow below commands:

```bash
git clone https://github.com/hackmdio/docker-hackmd.git ## clone to local
cd docker-hackmd ## enter the directory
vim docker-compose.yml ## if you need to change any db password or name
vim hackmd/config.js ## if you need to change any config (when you change the db things)
docker-compose up ## this might take some time
```

The default port is 3000  

## Update

Start your docker and enter the terminal, follow below commands:

```bash
cd docker-hackmd ## enter the directory
git pull ## pull new commits
docker-compose build --no-cache ## rebuild container
docker-compose up ## turn on
```

## Backup

Start your docker and enter the terminal, follow below commands:

- run `docker ps` to check all your containers
```bash
➜  ~  docker ps
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                    NAMES
2c04d7b1b8d4        dockerhackmd_hackmd   "/bin/bash /hackmd/do"   3 days ago          Up 17 seconds       0.0.0.0:3000->3000/tcp   dockerhackmd_hackmd_1
48d90ef50ef6        mongo                 "/entrypoint.sh mongo"   3 days ago          Up 18 seconds       27017/tcp                dockerhackmd_db-mongo_1
4949b888c1cb        postgres              "/docker-entrypoint.s"   3 days ago          Up 18 seconds       5432/tcp                 dockerhackmd_db-postgres_1
```
- backup postgresql by `docker exec <postgresql_container_id> pg_dump hackmd -U postgres > <postgresql_backup_name>`
```bash
➜  ~  docker exec 4949b888c1cb pg_dump hackmd -U postgres > postgresql_backup.sql
```
- backup monogodb by `docker exec <monogodb_container_id> mongodump -d hackmd -o <monogodb_backup_name>`
```bash
➜  ~  docker exec 48d90ef50ef6 mongodump -d hackmd -o mongodb_backup
```
- copy your backup out of container by `docker cp <container_id>:<backup_path> <host_path>`

**Happy HackMD :smile:**
