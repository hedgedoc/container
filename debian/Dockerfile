FROM node:12.19.0-slim

# Build arguments to change source url, branch or tag
ARG CODIMD_REPOSITORY=https://github.com/codimd/server.git
ARG VERSION=master
ARG UID=10000

# Set some default config variables
ARG DEBIAN_FRONTEND=noninteractive
ENV DOCKERIZE_VERSION=v0.6.1
ENV NODE_ENV=production

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      ca-certificates \
      wget && \
    rm -r /var/lib/apt/lists/*

RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Add configuraton files
COPY ["resources/config.json", "resources/.sequelizerc", "/files/"]

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN export dev_apt=( \
      "bzip2" \
      "git" \
      "jq" \
    ) && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
      "${dev_apt[@]}" \
      # Add fonts for PDF export
      fonts-noto \
      gosu && \
    \
    # Clone the source
    git clone --depth 1 --branch "$VERSION" "$CODIMD_REPOSITORY" /codimd && \
    # Print the cloned version and clean up git files
    cd /codimd && \
    git log --pretty=format:'%ad %h %d' --abbrev-commit --date=short -1 && echo && \
    git rev-parse HEAD > /tmp/gitref && \
    rm -rf /codimd/.git && \
    \
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
    npm run build && \
    \
    # Clean up this layer
    yarn install && \
    yarn cache clean && \
    apt-get autoremove --purge -qy "${dev_apt[@]}" && \
    rm -r /var/lib/apt/lists/* && \
    # Create codimd user
    adduser --uid $UID --home /codimd/ --disabled-password --system codimd && \
    chown -R codimd /codimd/

WORKDIR /codimd
EXPOSE 3000

COPY ["resources/docker-entrypoint.sh", "/usr/local/bin/docker-entrypoint.sh"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["node", "app.js"]
