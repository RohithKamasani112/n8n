# =========================================
# n8n Custom Dockerfile (Fixed)
# =========================================

# Use a stable Node base image
ARG NODE_VERSION=22.18.0
FROM node:${NODE_VERSION}-alpine AS builder

# Install system dependencies
RUN apk add --no-cache \
    git \
    openssh \
    openssl \
    graphicsmagick \
    tini \
    tzdata \
    ca-certificates \
    libc6-compat \
    jq \
    bash \
    fontconfig \
    msttcorefonts-installer && \
    update-ms-fonts && fc-cache -f && \
    apk del msttcorefonts-installer

# Install full-icu and n8n
RUN npm install -g full-icu@1.5.0 n8n

# =========================================
# Final Runtime Image
# =========================================
FROM node:${NODE_VERSION}-alpine

# Copy everything from builder
COPY --from=builder / /

WORKDIR /home/node

# Set environment variables
ENV NODE_ENV=production
ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu
ENV N8N_PORT=5678
ENV N8N_BASIC_AUTH_ACTIVE=false
ENV N8N_ENCRYPTION_KEY="changemeplease"

EXPOSE 5678

# Use tini as entrypoint (handles PID 1 issues)
ENTRYPOINT ["tini", "--"]

# Run n8n by default
CMD ["n8n"]
