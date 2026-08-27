FROM docker.io/library/node:16.14.2-bullseye-slim@sha256:d54981fe891c9e3442ea05cb668bc8a2a3ee38609ecce52c7b5a609fadc6f64b AS base

FROM base AS builder


RUN apt-get update && apt-get install --no-install-recommends -y git jq ca-certificates python-is-python3 build-essential


# Build arguments to change source url, branch or tag
ARG CODIMD_REPOSITORY
ARG HEDGEDOC_REPOSITORY=https://github.com/hedgedoc/hedgedoc.git
ARG VERSION=master
RUN if [ -n "${CODIMD_REPOSITORY}" ]; then echo "CODIMD_REPOSITORY is deprecated. Please use HEDGEDOC_REPOSITORY instead" && exit 1; fi

# Clone the source and remove git repository but keep the HEAD file
RUN git clone --depth 1 --branch "$VERSION" "$HEDGEDOC_REPOSITORY" /hedgedoc
RUN git -C /hedgedoc log --pretty=format:'%ad %h %d' --abbrev-commit --date=short -1
RUN git -C /hedgedoc rev-parse HEAD > /tmp/gitref
RUN rm -rf /hedgedoc/.git/*
RUN mv /tmp/gitref /hedgedoc/.git/HEAD
RUN jq ".repository.url = \"${HEDGEDOC_REPOSITORY}\"" /hedgedoc/package.json > /hedgedoc/package.new.json
RUN mv /hedgedoc/package.new.json /hedgedoc/package.json


# Install app dependencies and build
WORKDIR /hedgedoc
RUN yarn install --production=false --frozen-lockfile
RUN yarn run build
RUN yarn install --production=true --frozen-lockfile
RUN rm -f /hedgedoc/config.json
RUN ln -s /files/config.json /hedgedoc/config.json
COPY --chown=$UID /resources/healthcheck.mjs /hedgedoc/healthcheck.mjs

# Use distroless image
FROM gcr.io/distroless/nodejs:16@sha256:2b0fe69900014a74bc85fd4588e86b90139777a8fa7e2feea1f14447ea82e651

ARG UID=10000
ENV NODE_ENV=production
ENV UPLOADS_MODE=0700

COPY --chown=$UID --from=builder /hedgedoc /hedgedoc
COPY ["resources/config.json", "/files/"]

HEALTHCHECK --interval=5s CMD node healthcheck.mjs
WORKDIR /hedgedoc
EXPOSE 3000
USER $UID

CMD ["app.js"]
