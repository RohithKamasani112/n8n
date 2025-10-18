# --- Stage 1: Build stage ---
FROM node:22-alpine AS build

# Install build tools
RUN apk add --no-cache python3 make g++ git

# Enable pnpm (used by official n8n)
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /data/n8n

# Copy all source
COPY . .

# Install dependencies & build
RUN pnpm install --frozen-lockfile && pnpm build

# --- Stage 2: Runtime stage ---
FROM node:22-alpine

# Install tini for process handling
RUN apk add --no-cache tini

# Set environment variables
ENV NODE_ENV=production \
    N8N_PORT=5678 \
    N8N_BASIC_AUTH_ACTIVE=false

WORKDIR /data/n8n

# Copy compiled app
COPY --from=build /data/n8n /data/n8n

# Expose port
EXPOSE 5678

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["n8n", "start"]
