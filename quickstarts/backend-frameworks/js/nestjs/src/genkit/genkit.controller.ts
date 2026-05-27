import { Controller, Post, Req, Res } from '@nestjs/common';
import { Request, Response } from 'express';
import { fetchHandlers } from '@genkit-ai/fetch';
import { Readable } from 'node:stream';
import { bargainChefFlow } from './bargainChefFlow';

const handleFlow = fetchHandlers([bargainChefFlow], '/genkit');

@Controller('genkit')
export class GenkitController {
  @Post('*')
  async handleGenkit(@Req() req: Request, @Res() res: Response) {
    const url = new URL(req.url, `${req.protocol}://${req.get('host')}`);
    const headers = new Headers();
    for (const [key, value] of Object.entries(req.headers)) {
      if (value === undefined) continue;
      if (Array.isArray(value)) {
        value.forEach((v) => headers.append(key, v));
      } else {
        headers.set(key, String(value));
      }
    }

    const webRequest = new Request(url, {
      method: req.method,
      headers,
      body:
        req.method !== 'GET' && req.method !== 'HEAD'
          ? JSON.stringify(req.body)
          : undefined,
    });

    const webResponse = await handleFlow(webRequest);
    res.status(webResponse.status);
    webResponse.headers.forEach((value, key) => {
      res.setHeader(key, value);
    });

    if (webResponse.body) {
      Readable.fromWeb(webResponse.body as any).pipe(res);
    } else {
      res.end();
    }
  }
}
