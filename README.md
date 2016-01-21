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

**Happy HackMD :smile:**
