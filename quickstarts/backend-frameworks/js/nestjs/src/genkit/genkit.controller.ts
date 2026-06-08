import { Controller, Post, Req, Res } from '@nestjs/common';
import type { Request, Response } from 'express';
import { expressHandler } from '@genkit-ai/express';
import { bargainChefFlow } from './bargainChefFlow';

@Controller()
export class GenkitController {
  private readonly handleBargainChef = expressHandler(bargainChefFlow);

  @Post('bargainChefFlow')
  bargainChef(@Req() req: Request, @Res() res: Response) {
    return this.handleBargainChef(req, res);
  }
}
