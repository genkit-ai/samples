import { Module } from '@nestjs/common';
import { GenkitController } from './genkit/genkit.controller';

@Module({
  controllers: [GenkitController],
})
export class AppModule {}
