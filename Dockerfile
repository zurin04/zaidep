# Multi-stage Docker build for Crypto Airdrop Platform
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:20-alpine AS production

# Install system dependencies
RUN apk add --no-cache \
    postgresql-client \
    curl \
    bash

# Create app user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S crypto -u 1001

# Set working directory
WORKDIR /app

# Copy built application from builder stage
COPY --from=builder --chown=crypto:nodejs /app/dist ./dist
COPY --from=builder --chown=crypto:nodejs /app/server ./server
COPY --from=builder --chown=crypto:nodejs /app/shared ./shared
COPY --from=builder --chown=crypto:nodejs /app/db ./db
COPY --from=builder --chown=crypto:nodejs /app/package*.json ./
COPY --from=builder --chown=crypto:nodejs /app/node_modules ./node_modules

# Copy additional required files
COPY --chown=crypto:nodejs drizzle.config.ts ./
COPY --chown=crypto:nodejs tsconfig.json ./

# Create log directory
RUN mkdir -p /var/log/crypto-airdrop && \
    chown -R crypto:nodejs /var/log/crypto-airdrop

# Switch to non-root user
USER crypto

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/api/health || exit 1

# Start command
CMD ["npm", "start"]