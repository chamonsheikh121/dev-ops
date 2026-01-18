# ======================
# Build stage
# ======================
FROM node:20-alpine AS builder

RUN npm install -g pnpm

WORKDIR /app

# 🔥 DUMMY DATABASE_URL (BUILD TIME ONLY)
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"

COPY package.json pnpm-lock.yaml ./
COPY prisma.config.ts ./

RUN pnpm install

COPY prisma ./prisma
RUN pnpx prisma generate   # ✅ now works

COPY . .
RUN pnpm run build


# ======================
# Production stage
# ======================
FROM node:20-alpine AS production

RUN npm install -g pnpm

WORKDIR /app

# 🔥 SAME DUMMY HERE
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"

COPY package.json pnpm-lock.yaml ./
COPY prisma.config.ts ./

RUN pnpm install --prod

COPY prisma ./prisma
RUN pnpx prisma generate   # ✅ works

COPY --from=builder /app/dist ./dist

EXPOSE 3000

# Create an entrypoint script
COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# 🔥 REAL DATABASE_URL comes from docker-compose at runtime
ENTRYPOINT ["/app/docker-entrypoint.sh"]
