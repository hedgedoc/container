FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y upgrade && apt-get install -y apt-utils curl vim

# nodejs, npm
RUN apt-get install -y nodejs nodejs-legacy
RUN curl -L https://npmjs.org/install.sh | sh

# git
RUN apt-get install -y git

# source
RUN mkdir /hackmd
WORKDIR /hackmd
RUN git clone https://github.com/hackmdio/hackmd.git /hackmd
RUN git checkout 9586e2057f9ede5c0514ecf5f44b72b88e3c6129

# npm, deps
RUN apt-get install -y python build-essential make gcc g++ libkrb5-dev
RUN npm install

# add config
ADD config.js /hackmd/config.js
ADD docker-entrypoint.sh /hackmd/docker-entrypoint.sh

# psql client
RUN apt-get install -y postgresql-client-9.4

EXPOSE 3000

CMD ["/bin/bash", "/hackmd/docker-entrypoint.sh"]

