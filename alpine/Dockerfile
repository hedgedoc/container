FROM node:16.6.2-alpine@sha256:2d7a22f6d738af0dc829d181e8a95d6239460a185f2dafee531b3c79b6c9334c AS base

FROM base AS builder
# Build arguments to change source url, branch or tag
ARG CODIMD_REPOSITORY
ARG HEDGEDOC_REPOSITORY=https://github.com/hedgedoc/hedgedoc.git
ARG VERSION=master
RUN if [ -n "${CODIMD_REPOSITORY}" ]; then echo "CODIMD_REPOSITORY is deprecated. Please use HEDGEDOC_REPOSITORY instead" && exit 1; fi

# Clone the source and remove git repository but keep the HEAD file
RUN apk update && apk add git jq
RUN git clone --depth 1 --branch "$VERSION" "$HEDGEDOC_REPOSITORY" /hedgedoc
RUN git -C /hedgedoc log --pretty=format:'%ad %h %d' --abbrev-commit --date=short -1
RUN git -C /hedgedoc rev-parse HEAD > /tmp/gitref
RUN rm -rf /hedgedoc/.git/*
RUN mv /tmp/gitref /hedgedoc/.git/HEAD
RUN jq ".repository.url = \"${HEDGEDOC_REPOSITORY}\"" /hedgedoc/package.json > /hedgedoc/package.new.json
RUN mv /hedgedoc/package.new.json /hedgedoc/package.json

# Install app dependencies and build
WORKDIR /hedgedoc
RUN yarn install --production=false --pure-lockfile
RUN yarn run build
RUN yarn install --production=true --pure-lockfile


FROM base
ARG UID=10000
ENV NODE_ENV=production

COPY --chown=$UID --from=builder /hedgedoc /hedgedoc

# Add configuraton files
COPY ["resources/config.json", "/files/"]

# For backwards compatibility
RUN ln -s /hedgedoc /codimd

# Install all dependencies and build project
RUN apk add --no-cache --no-progress --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ gosu

# Symlink configuration files
RUN rm -f /hedgedoc/config.json
RUN ln -s /files/config.json /hedgedoc/config.json

# Create hedgedoc user
RUN adduser -u $UID -h /hedgedoc/ -D -S hedgedoc

WORKDIR /hedgedoc
EXPOSE 3000

COPY ["resources/docker-entrypoint.sh", "/usr/local/bin/docker-entrypoint.sh"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["npm", "start"]
