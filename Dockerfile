# --- Base build stage ---
FROM node:20-alpine AS build

# Install dependencies for building
RUN apk add --no-cache python3 make g++ git

# Set working directory
WORKDIR /data/n8n

# Copy source code
COPY . .

# Install dependencies & build
RUN npm ci && npm run build

# --- Final runtime stage ---
FROM node:20-alpine

# Install tini (to handle PID 1 properly)
RUN apk add --no-cache tini

ENV NODE_ENV=production \
    N8N_PORT=5678 \
    N8N_BASIC_AUTH_ACTIVE=false

# Set working directory
WORKDIR /data/n8n

# Copy built app from previous stage
COPY --from=build /data/n8n /data/n8n

# Expose default port
EXPOSE 5678

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Start n8n
CMD ["n8n", "start"]
