CodiMD container
===

[![Build Status](https://travis-ci.org/hackmdio/codimd-container.svg?branch=master)](https://travis-ci.org/hackmdio/codimd-container)
[![#CodiMD on matrix.org](https://img.shields.io/badge/Matrix.org-%23CodiMD@matrix.org-green.svg)](https://riot.im/app/#/room/#codimd:matrix.org)
[![Gitter](https://badges.gitter.im/hackmdio/hackmd.svg)](https://gitter.im/hackmdio/hackmd?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Try in PWD](https://cdn.rawgit.com/play-with-docker/stacks/cff22438/assets/images/button.png)](http://play-with-docker.com?stack=https://github.com/hackmdio/codimd-container/raw/master/docker-compose.yml&stack_name=hackmd)

**Debian based version:**

[![](https://images.microbadger.com/badges/version/hackmdio/hackmd:latest.svg)](https://microbadger.com/images/hackmdio/hackmd "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/hackmdio/hackmd:latest.svg)](https://microbadger.com/images/hackmdio/hackmd "Get your own image badge on microbadger.com")


**Alpine based version:**

[![](https://images.microbadger.com/badges/version/hackmdio/hackmd:alpine.svg)](https://microbadger.com/images/hackmdio/hackmd:alpine "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/hackmdio/hackmd:alpine.svg)](https://microbadger.com/images/hackmdio/hackmd:alpine "Get your own image badge on microbadger.com")


# Prerequisite
* git (https://git-scm.com/)
* docker (https://www.docker.com/community-edition)
* docker-compose (https://docs.docker.com/compose/install/)

See more here: https://docs.docker.com/


# Usage

## Get started

1. Install docker and docker-compose, "Docker for Windows" or "Docker for Mac"
2. Run `git clone https://github.com/hackmdio/codimd-container.git`
3. Change to the directory `codimd-container` directory
4. Run `docker-compose up` in your terminal
5. Wait until see the log `HTTP Server listening at port 3000`, it will take few minutes based on your internet connection.
6. Open http://127.0.0.1:3000


## Update

Start your docker and enter the terminal, follow below commands:

```bash
cd codimd-container ## enter the directory
git pull ## pull new commits
docker-compose pull ## pull new containers
docker-compose up ## turn on
```

### Migrate from docker-hackmd

If you used the [`docker-hackmd`](https://github.com/hackmdio/docker-hackmd) repository before, migrating to [`codimd-container`](https://github.com/hackmdio/codimd-container) is easy.

Since codimd-container is basically a fork of `docker-hackmd`, all you need to do is replacing the upstream URL.

```bash
git remote set-url origin https://github.com/hackmdio/codimd-container.git
git pull
```

Now you can follow the regular update steps.

### [migration-to-0.5.0](https://github.com/hackmdio/migration-to-0.5.0)


We don't use LZString to compress socket.io data and DB data after version 0.5.0.
Please run the migration tool if you're upgrading from the old version.

1. Stop your CodiMD containers
2. Modify `docker-compose.yml`, add expose ports `5432` to `hackmdPostgres`
3. `docker-compose up` to start your codimd containers
4. Backup DB (see below)
5. Git clone above `migration-to-0.5.0` and `npm install` (see more on above link)
6. Modify `config.json` in `migration-to-0.5.0`, change its `username`, `password` and `host` to your docker
7. Run migration (see more on above link)
8. Stop your codimd containers
9. Modify `docker-compose.yml`, remove expose ports `5432` in `hackmdPostgres`
10. git pull in `codimd-container`, update to version 0.5.0 (see below)



## Backup

Start your docker and enter the terminal, follow below commands:

```bash
 docker-compose exec database pg_dump hackmd -U hackmd  > backup.sql
```


## Restore

Similar to backup steps, but last command is
```bash
cat backup.sql | docker exec -i $(docker-compose ps -q database) psql -U hackmd
```

# Kubernetes

To install use `helm install stable/hackmd`.

For all further details, please check out the offical HackMD  [K8s helm chart](https://github.com/kubernetes/charts/tree/master/stable/hackmd).

# Custom build

The default setting would use pre-build docker image, if you want to build your own containers
uncomment the `build` section in the [`docker-compose.yml`](https://github.com/hackmdio/codimd-container/blob/master/docker-compose.yml) and edit the [`config.json`](https://github.com/hackmdio/codimd-container/blob/master/resources/config.json).

If you change the database settings and don't use the `HMD_DB_URL` make sure you edit the [`.sequelizerc`](https://github.com/hackmdio/codimd-container/blob/master/resources/.sequelizerc).


# License

View [license information](https://github.com/hackmdio/codimd) for the software contained in this image.


# Supported Docker versions

This image is officially supported on Docker version 17.03.1-CE.

Support for older versions (down to 1.12) is provided on a best-effort basis.

Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker daemon.


# User Feedback

## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/hackmdio/codimd-container/issues).

You can also reach many of the project maintainers via our [`#codimd:matrix.org`](https://matrix.to/#/#codimd:matrix.org) or the `hackmd` channel on [Gitter](https://gitter.im/hackmdio/hackmd).


## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.


**Happy CodiMD :smile:**
