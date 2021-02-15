HedgeDoc container
===

![Test status](https://github.com/hedgedoc/container/workflows/Tests/badge.svg)
[![#hedgedoc on matrix.org](https://img.shields.io/badge/Matrix.org-%23hedgedoc@matrix.org-green.svg)](https://chat.hedgedoc.org)
[![Try in PWD](https://cdn.rawgit.com/play-with-docker/stacks/cff22438/assets/images/button.png)](http://play-with-docker.com?stack=https://github.com/hedgedoc/container/raw/master/docker-compose.yml&stack_name=hedgedoc)

HedgeDoc docker images are available in two flavors: Debian and Alpine. These are available at quay.io:

<https://quay.io/repository/hedgedoc/hedgedoc>

```
docker pull quay.io/hedgedoc/hedgedoc:1.7.2-debian
docker pull quay.io/hedgedoc/hedgedoc:1.7.2-alpine
```

We recommend using the Debian version for production deployments and Alpine for expert setups.

# Prerequisite

* git (https://git-scm.com/)
* docker (https://www.docker.com/community-edition)
* docker-compose (https://docs.docker.com/compose/install/)

See more here: https://docs.docker.com/


# Usage

## Get started

1. Install docker and docker-compose, "Docker for Windows" or "Docker for Mac"
2. Run `git clone https://github.com/hedgedoc/container.git hedgedoc-container`
3. Change to the directory `hedgedoc-container` directory
4. Run `docker-compose up` in your terminal
5. Wait until see the log `HTTP Server listening at port 3000`, it will take few minutes based on your internet connection.
6. Open http://127.0.0.1:3000


## Update

Start your docker and enter the terminal, follow below commands:

```bash
cd hedgedoc-container ## enter the directory
git pull ## pull new commits
docker-compose pull ## pull new containers
docker-compose up ## turn on
```


### Configuration

You can configure your container with a config file or with env vars. Check out https://docs.hedgedoc.org/configuration/ for more details.


### Migrate from 1.6

Together with the update to HedgeDoc 1.7, the database user name, password and database name have been changed in `docker-compose.yml`.

In order to migrate the existing database to the new default credentials, run

```bash
docker-compose exec database createuser --superuser -Uhackmd postgres
docker-compose exec database psql -Upostgres -c "alter role hackmd rename to hedgedoc; alter role hedgedoc with password 'password'; alter database hackmd rename to hedgedoc;"
```

before running `docker-compose up`.


### Migrate from docker-hackmd

If you used the [`docker-hackmd`](https://github.com/hackmdio/docker-hackmd) repository before, migrating to [`hedgedoc-container`](https://github.com/hedgedoc/container) is easy.

Since `hedgedoc-container` is basically a fork of `docker-hackmd`, all you need to do is replace the upstream URL:

```bash
git remote set-url origin https://github.com/hedgedoc/container.git
git pull
```

Now you can follow the regular update steps.


## Backup

Start your docker and enter the terminal, follow below commands:

```bash
 docker-compose exec database pg_dump hedgedoc -U hedgedoc > backup.sql
```


## Restore

Before starting the application for the first time, run these commands:

```bash
docker-compose up -d database
cat backup.sql | docker exec -i $(docker-compose ps -q database) psql -U hedgedoc
```

# Custom build

The default setting is to use pre-built docker images. If you want to build your
own containers uncomment the `build` section in the
[`docker-compose.yml`](https://github.com/hedgedoc/container/blob/master/docker-compose.yml)
and edit the
[`config.json`](https://github.com/hedgedoc/container/blob/master/resources/config.json).

If you change the database settings and don't use the `CMD_DB_URL` make sure
you edit the
[`.sequelizerc`](https://github.com/hedgedoc/container/blob/master/resources/.sequelizerc).


# License

View [license information](https://github.com/hedgedoc/hedgedoc) for the
software contained in this image.


# Supported Docker versions

This image is officially supported on Docker version 17.03.1-CE.

Support for older versions (down to 1.12) is provided on a best-effort basis.

Please see [the Docker installation
documentation](https://docs.docker.com/installation/) for details on how to
upgrade your Docker daemon.


# User Feedback

## Issues

If you have any problems with or questions about this image, please contact us
through a [GitHub issue](https://github.com/hedgedoc/container/issues).

You can also reach many of the project maintainers via our matrix room
[`#hedgedoc:matrix.org`](https://chat.hedgedoc.org).


## Contributing

You are invited to contribute new features, fixes, or updates, large or small;
we are always thrilled to receive pull requests, and do our best to process
them as fast as we can.


**Happy HedgeDoc :smile:**
