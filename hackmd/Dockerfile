FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y upgrade && apt-get install -y apt-utils curl vim

# nodejs, npm
RUN curl -sL https://deb.nodesource.com/setup_5.x | bash -
RUN apt-get install -y nodejs

# git
RUN apt-get install -y git

# source
RUN mkdir /hackmd
WORKDIR /hackmd
RUN git clone https://github.com/hackmdio/hackmd.git /hackmd
RUN git checkout 13d61fe42db31878e76be3b617402e6527246990

# npm, deps
RUN apt-get install -y python build-essential make gcc g++
RUN npm install

# bower
RUN npm install -g bower
RUN bower install --allow-root

# add config
ADD config.json /hackmd/config.json
ADD docker-entrypoint.sh /hackmd/docker-entrypoint.sh

# psql client
RUN apt-get install -y postgresql-client-9.4

EXPOSE 3000

CMD ["/bin/bash", "/hackmd/docker-entrypoint.sh"]
