FROM node:12.19.0-alpine

# Build arguments to change source url, branch or tag
ARG CODIMD_REPOSITORY=https://github.com/codimd/server.git
ARG VERSION=master
ARG UID=10000

# Set some default config variables
ENV DOCKERIZE_VERSION=v0.6.1
ENV NODE_ENV=production

# Disable PDF export on alpine
# PhantomJS is broken on alpine and crashes CodiMD
ENV CMD_ALLOW_PDF_EXPORT=false

RUN apk add --no-cache --virtual .download \
      ca-certificates \
      wget && \
    wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    apk del .download

# Add configuraton files
COPY ["resources/config.json", "resources/.sequelizerc", "/files/"]

# Install all dependencies and build project
RUN apk add --no-cache --virtual .dep \
      bash \
      build-base \
      git \
      jq \
      openssl-dev \
      python && \
    apk add --no-cache --no-progress --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
      gosu && \
    # Clone the source
    git clone --depth 1 --branch "$VERSION" "$CODIMD_REPOSITORY" /codimd && \
    # Print the cloned version and clean up git files
    cd /codimd && \
    git log --pretty=format:'%ad %h %d' --abbrev-commit --date=short -1 && echo && \
    git rev-parse HEAD > /tmp/gitref && \
    rm -rf /codimd/.git && \
    # Mime the git repository for fullversion
    mkdir /codimd/.git && \
    mv /tmp/gitref /codimd/.git/HEAD && \
    jq ".repository.url = \"${CODIMD_REPOSITORY}\"" /codimd/package.json > /codimd/package.new.json && \
    mv /codimd/package.new.json /codimd/package.json && \
    \
    # Symlink configuration files
    rm -f /codimd/config.json && \
    ln -s /files/config.json /codimd/config.json && \
    rm -f /codimd/.sequelizerc && \
    ln -s /files/.sequelizerc /codimd/.sequelizerc && \
    \
    # Install NPM dependencies and build project
    yarn install --pure-lockfile && \
    yarn install --production=false --pure-lockfile && \
    #yarn global add webpack && \
    npm run build && \
    \
    # Clean up this layer
    yarn install && \
    yarn cache clean && \
    apk del .dep && \
    \
    adduser -u $UID -h /codimd/ -D -S codimd && \
    chown -R codimd /codimd/

WORKDIR /codimd
EXPOSE 3000

COPY ["resources/docker-entrypoint.sh", "/usr/local/bin/docker-entrypoint.sh"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["node", "app.js"]
