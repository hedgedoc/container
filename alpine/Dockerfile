FROM node:12.20.0-alpine@sha256:a9ee412baa5c130dea5f8483e95890f8d7e499dda196973f4397189b0bb98244

# Build arguments to change source url, branch or tag
ARG HEDGEDOC_REPOSITORY=https://github.com/hedgedoc/hedgedoc.git
ARG VERSION=master
ARG UID=10000

ARG CODIMD_REPOSITORY
RUN if [ -n "${CODIMD_REPOSITORY}" ]; then echo "CODIMD_REPOSITORY is deprecated. Please use HEDGEDOC_REPOSITORY instead" && exit 1; fi

# Set some default config variables
ENV DOCKERIZE_VERSION=v0.6.1
ENV NODE_ENV=production

# Disable PDF export on alpine
# PhantomJS is broken on alpine and crashes HedgeDoc
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
    git clone --depth 1 --branch "$VERSION" "$HEDGEDOC_REPOSITORY" /hedgedoc && \
    ln -s /hedgedoc /codimd && \
    # Print the cloned version and clean up git files
    cd /hedgedoc && \
    git log --pretty=format:'%ad %h %d' --abbrev-commit --date=short -1 && echo && \
    git rev-parse HEAD > /tmp/gitref && \
    rm -rf /hedgedoc/.git && \
    # Mime the git repository for fullversion
    mkdir /hedgedoc/.git && \
    mv /tmp/gitref /hedgedoc/.git/HEAD && \
    jq ".repository.url = \"${HEDGEDOC_REPOSITORY}\"" /hedgedoc/package.json > /hedgedoc/package.new.json && \
    mv /hedgedoc/package.new.json /hedgedoc/package.json && \
    \
    # Symlink configuration files
    rm -f /hedgedoc/config.json && \
    ln -s /files/config.json /hedgedoc/config.json && \
    rm -f /hedgedoc/.sequelizerc && \
    ln -s /files/.sequelizerc /hedgedoc/.sequelizerc && \
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
    adduser -u $UID -h /hedgedoc/ -D -S hedgedoc && \
    chown -R hedgedoc /hedgedoc/

WORKDIR /hedgedoc
EXPOSE 3000

COPY ["resources/docker-entrypoint.sh", "/usr/local/bin/docker-entrypoint.sh"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["npm", "start"]
