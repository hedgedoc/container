FROM node:12.22.1-slim@sha256:601223e196e56397bf7cdd99ea3f6d94c8574219636b36eec80eda841e9c1a86 AS base

FROM base AS basebuilder
RUN apt-get update

FROM basebuilder AS dockerize
# Download and extract dockerize, used in resources/docker-entrypoint.sh
ENV DOCKERIZE_VERSION=v0.6.1
RUN apt-get install --no-install-recommends -y ca-certificates wget
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
RUN tar -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
RUN rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz


FROM basebuilder AS builder
# Build arguments to change source url, branch or tag
ARG CODIMD_REPOSITORY
ARG HEDGEDOC_REPOSITORY=https://github.com/hedgedoc/hedgedoc.git
ARG VERSION=master
RUN if [ -n "${CODIMD_REPOSITORY}" ]; then echo "CODIMD_REPOSITORY is deprecated. Please use HEDGEDOC_REPOSITORY instead" && exit 1; fi

# Clone the source and remove git repository but keep the HEAD file
RUN apt-get install --no-install-recommends -y git jq ca-certificates
RUN git clone --depth 1 --branch "$VERSION" "$HEDGEDOC_REPOSITORY" /hedgedoc
RUN git -C /hedgedoc log --pretty=format:'%ad %h %d' --abbrev-commit --date=short -1
RUN git -C /hedgedoc rev-parse HEAD > /tmp/gitref
RUN rm -rf /hedgedoc/.git/*
RUN mv /tmp/gitref /hedgedoc/.git/HEAD
RUN jq ".repository.url = \"${HEDGEDOC_REPOSITORY}\"" /hedgedoc/package.json > /hedgedoc/package.new.json
RUN mv /hedgedoc/package.new.json /hedgedoc/package.json

# Install app dependencies and build
RUN apt-get install --no-install-recommends -y bzip2
WORKDIR /hedgedoc
RUN yarn install --production=false --pure-lockfile
RUN yarn run build
RUN rm -rf node_modules
RUN yarn install --production=true --pure-lockfile


FROM base
ARG UID=10000
ENV NODE_ENV=production

RUN apt-get update && \
    apt-get install --no-install-recommends -y fonts-noto gosu && \
    rm -r /var/lib/apt/lists/*

COPY --from=dockerize dockerize /usr/local/bin/
COPY --chown=$UID --from=builder /hedgedoc /hedgedoc

# Add configuraton files
COPY ["resources/config.json", "/files/"]

# For backwards compatibility
RUN ln -s /hedgedoc /codimd

# Symlink configuration files
RUN rm -f /hedgedoc/config.json
RUN ln -s /files/config.json /hedgedoc/config.json

# Create hedgedoc user
RUN adduser --uid $UID --home /hedgedoc/ --disabled-password --system hedgedoc

WORKDIR /hedgedoc
EXPOSE 3000

COPY ["resources/docker-entrypoint.sh", "/usr/local/bin/docker-entrypoint.sh"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["npm", "start"]
