FROM --platform=linux/amd64 node:20-alpine

WORKDIR /var/www

# Install dependencies
RUN apk add --no-cache \
    git \
    make \
    g++

# Create a non-root user with a different UID
RUN addgroup -g 1001 node_user && \
    adduser -u 1001 -G node_user -s /bin/sh -D node_user

USER node_user 