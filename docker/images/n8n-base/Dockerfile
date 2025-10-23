# =========================================
# n8n Custom Dockerfile (Fixed for Kubernetes)
# =========================================

# Use a stable Node base image
FROM node:22.18.0-alpine

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

# Install full-icu and n8n globally
RUN npm install -g full-icu@1.5.0 n8n

# Ensure /usr/local/bin is in PATH for all users
ENV PATH=/usr/local/bin:$PATH

# Set working directory
WORKDIR /home/node

# Set environment variables
ENV NODE_ENV=production
ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu
ENV N8N_PORT=5678
ENV N8N_BASIC_AUTH_ACTIVE=false
ENV N8N_ENCRYPTION_KEY="changemeplease"

# Expose n8n port
EXPOSE 5678

# Use tini as entrypoint (handles PID 1 issues)
ENTRYPOINT ["tini", "--"]

# Run n8n by default
CMD ["n8n"]
