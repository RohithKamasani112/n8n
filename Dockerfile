# --- Stage 1: Build stage ---
FROM node:20-alpine AS build

# Install build tools
RUN apk add --no-cache python3 make g++ git

WORKDIR /data/n8n

# Copy all files
COPY . .

# Install dependencies and build
RUN npm ci && npm run build

# --- Stage 2: Production stage ---
FROM node:20-alpine

# Install tini for proper process handling
RUN apk add --no-cache tini

# Environment setup
ENV NODE_ENV=production \
    N8N_PORT=5678 \
    N8N_BASIC_AUTH_ACTIVE=false

WORKDIR /data/n8n

# Copy built files
COPY --from=build /data/n8n /data/n8n

# Expose n8n port
EXPOSE 5678

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Default command to start n8n
CMD ["n8n", "start"]
