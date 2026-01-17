/* eslint-disable @typescript-eslint/no-unsafe-member-access */
import { Module } from '@nestjs/common';
import { CacheModule } from '@nestjs/cache-manager';
import { redisStore } from 'cache-manager-redis-yet';

@Module({
  imports: [
    CacheModule.registerAsync<any>({
      useFactory: async () => {
        // Use process.env directly to ensure Docker environment variables are read
        const redisHost = process.env.REDIS_HOST || 'localhost';
        const redisPort = parseInt(process.env.REDIS_PORT || '6379', 10);

        console.log('🔧 Redis Configuration:', {
          host: redisHost,
          port: redisPort,
        });

        try {
          const store = await redisStore({
            socket: {
              host: redisHost,
              port: redisPort,
              family: 4, // Force IPv4 only to avoid IPv6 localhost attempts
              reconnectStrategy: false, // Disable automatic reconnection to prevent localhost retry errors
            },
            ttl: 60 * 1000, // milliseconds
          });

          console.log('✅ Redis Store Created Successfully');
          return { store };
        } catch (error) {
          console.error('❌ Redis Connection Error:', error.message);
          throw error;
        }
      },
      isGlobal: true,
    }),
  ],
  providers: [],
  controllers: [],
})
export class RedisModule {}
