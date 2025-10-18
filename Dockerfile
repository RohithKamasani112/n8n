# --- Stage 1: Build stage ---
FROM node:20-alpine AS build

# Install build tools
RUN apk add --no-cache python3 make g++ git

# Install pnpm (official n8n uses pnpm)
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /data/n8n

# Copy source code
COPY . .

# Install dependencies & build
RUN pnpm install --frozen-lockfile && pnpm build

# --- Stage 2: Runtime image ---
FROM node:20-alpine

# Install tini (PID 1 handler)
RUN apk add --no-cache tini

ENV NODE_ENV=production \
    N8N_PORT=5678 \
    N8N_BASIC_AUTH_ACTIVE=false

WORKDIR /data/n8n

# Copy built files from build stage
COPY --from=build /data/n8n /data/n8n

EXPOSE 5678

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["n8n", "start"]
