# --- Stage 1: Build n8n ---
FROM node:22.16.0-alpine AS builder

# Install build tools for native dependencies
RUN apk add --no-cache python3 make g++ git libc6-compat

# Enable pnpm (official n8n uses pnpm)
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set working directory
WORKDIR /data/n8n

# Copy source code
COPY . .

# Install dependencies and build
RUN pnpm install --frozen-lockfile --unsafe-perm --reporter=append-only
RUN pnpm build --reporter=append-only

# --- Stage 2: Runtime image ---
FROM node:22.16.0-alpine

# Install runtime dependencies
RUN apk add --no-cache tini graphicsmagick

# Set environment variables
ENV NODE_ENV=production \
    N8N_PORT=5678 \
    N8N_BASIC_AUTH_ACTIVE=false

# Set working directory
WORKDIR /data/n8n

# Copy built application from builder
COPY --from=builder /data/n8n /data/n8n

# Expose port
EXPOSE 5678

# Use tini as PID 1
ENTRYPOINT ["/sbin/tini", "--"]

# Start n8n
CMD ["n8n", "start"]
