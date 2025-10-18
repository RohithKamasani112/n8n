# --- Stage 1: Build ---
FROM node:22.17.0-bullseye-slim AS builder

# Install build tools
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    git \
    libc6-dev \
    bash \
 && rm -rf /var/lib/apt/lists/*

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /data/n8n

# Copy repo
COPY . .

# Install dependencies & build
RUN pnpm install --frozen-lockfile --unsafe-perm --reporter=append-only --shamefully-hoist
RUN pnpm build --reporter=append-only

# --- Stage 2: Runtime ---
FROM node:22.17.0-bullseye-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    graphicsmagick \
    tini \
 && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production \
    N8N_PORT=5678 \
    N8N_BASIC_AUTH_ACTIVE=false

WORKDIR /data/n8n

COPY --from=builder /data/n8n /data/n8n

EXPOSE 5678

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["n8n", "start"]
