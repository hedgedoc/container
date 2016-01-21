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
RUN git checkout 018beab583b5affb59321762388e376d5f123b0f

# npm, deps
RUN apt-get install -y python build-essential make gcc g++ libkrb5-dev
RUN npm install

# bower
RUN npm install -g bower
RUN bower install --allow-root

# add config
ADD config.js /hackmd/config.js
ADD docker-entrypoint.sh /hackmd/docker-entrypoint.sh

# psql client
RUN apt-get install -y postgresql-client-9.4

EXPOSE 3000

CMD ["/bin/bash", "/hackmd/docker-entrypoint.sh"]

