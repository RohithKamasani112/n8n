# =========================================
# STAGE 1: Builder (installs dependencies)
# =========================================
ARG NODE_VERSION=22.18.0
FROM node:${NODE_VERSION}-alpine AS builder

# Install fonts and OS dependencies
RUN apk --no-cache add --virtual .build-deps-fonts msttcorefonts-installer fontconfig && \
    update-ms-fonts && fc-cache -f && apk del .build-deps-fonts && \
    find /usr/share/fonts/truetype/msttcorefonts/ -type l -exec unlink {} \;

RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.22/main" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.22/community" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache git openssh openssl graphicsmagick tini tzdata ca-certificates libc6-compat jq && \
    npm install -g full-icu@1.5.0 n8n

# =========================================
# STAGE 2: Final Runtime Image
# =========================================
FROM node:${NODE_VERSION}-alpine

# Copy everything from builder
COPY --from=builder / /

# Set environment
ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu
ENV NODE_ENV=production
ENV N8N_PORT=5678
ENV N8N_BASIC_AUTH_ACTIVE=false
ENV N8N_ENCRYPTION_KEY="changemeplease"

WORKDIR /home/node
EXPOSE 5678

# Use tini as PID 1 (prevents zombie processes)
ENTRYPOINT ["tini", "--"]

# Default command to run n8n
CMD ["n8n"]
