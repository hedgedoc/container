FROM node:8.11.4-alpine

# Build arguments to change source url, branch or tag
ARG HACKMD_REPOSITORY=https://github.com/hackmdio/hackmd.git
ARG VERSION=master

# Set some default config variables
ENV DOCKERIZE_VERSION=v0.6.1
ENV NODE_ENV=production

# Disable PDF export on alpine
# PhantomJS is broken on alpine and crashes HackMD
ENV HMD_ALLOW_PDF_EXPORT=false

RUN apk add --no-cache --virtual .download wget  ca-certificates && \
    wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    apk del .download

ENV GOSU_VERSION 1.10
COPY resources/gosu-gpg.key /tmp/gosu.key
RUN set -ex; \
    \
    apk add --no-cache --virtual .gosu-deps \
        wget \
        ca-certificates \
        dpkg \
        gnupg \
        openssl \
    ; \
    \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    \
# verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --import /tmp/gosu.key; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    \
    chmod +x /usr/local/bin/gosu; \
# verify that the binary works
    gosu nobody true; \
    \
    apk del .gosu-deps

# Add configuraton files
COPY resources/config.json resources/.sequelizerc /files/

# Install all dependencies and build project
RUN apk add --no-cache --virtual .dep build-base python git bash && \
    # Clone the source
    git clone --depth 1 --branch $VERSION $HACKMD_REPOSITORY /hackmd && \
    # Print the cloned version and clean up git files
    cd /hackmd && \
    git log --pretty=format:'%ad %h %d' --abbrev-commit --date=short -1 && echo && \
    rm -rf /hackmd/.git && \
    # Symlink configuration files
    rm -f /hackmd/config.json && ln -s /files/config.json /hackmd/config.json && \
    rm -f /hackmd/.sequelizerc && ln -s /files/.sequelizerc /hackmd/.sequelizerc && \
    # Install NPM dependencies and build project
    yarn install --pure-lockfile && \
    yarn install --production=false --pure-lockfile && \
    yarn global add webpack && \
    npm run build && \
    # Clean up this layer
    yarn install && \
    yarn cache clean && \
    apk del .dep && \
    adduser -u 10000 -h /hackmd/ -D -S hackmd && \
    chown -R hackmd /hackmd/

WORKDIR /hackmd
EXPOSE 3000

# Add entrypoint and set command
COPY resources/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["node", "app.js"]
