# Use a Node.js image as the base, as n8n is built on Node
FROM node:20-alpine AS build

# Set the working directory for the application
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) to install dependencies
# This is done separately to leverage Docker layer caching
COPY package*.json ./

# Install application dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the application (if necessary, check n8n's specific build process)
# For many Node apps, this is not needed if running directly via 'node server.js'
# If n8n requires a specific build step, replace this with the actual command:
# RUN npm run build 

# --- Stage 2: Production Image (Smaller and more secure) ---
FROM node:20-alpine

# Set non-root user for better security
USER node

# Set environment variables for n8n (if required, replace with actual values)
# ENV NODE_ENV production
# ENV N8N_HOST=0.0.0.0

# Set the working directory
WORKDIR /home/node/app

# Copy the installed dependencies and application code from the build stage
COPY --from=build /app .

# Expose the default port for n8n
EXPOSE 5678

# Command to run the n8n application
CMD ["npm", "start"]
