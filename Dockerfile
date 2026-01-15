# Build stage
FROM node:20-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./
COPY prisma.config.ts ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy prisma schema and config
COPY prisma ./prisma

# Generate Prisma Client (set dummy DATABASE_URL for config loading)
RUN DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy" pnpx prisma generate

# Copy source code
COPY . .

# Build application
RUN pnpm run build

# Production stage
FROM node:20-alpine AS production

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./
COPY prisma.config.ts ./

# Install production dependencies only
RUN pnpm install --prod --frozen-lockfile

# Copy prisma schema and generate client
COPY prisma ./prisma
RUN DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy" pnpx prisma generate

# Copy built application from builder
COPY --from=builder /app/dist ./dist

# Expose application port
EXPOSE 5000

# Start application
CMD ["node", "dist/src/main"]
