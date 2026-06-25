import type { NextApiRequest, NextApiResponse } from 'next';
import { Readable } from 'node:stream';
import { fetchHandlers } from '@genkit-ai/fetch';
import { bargainChefFlow } from '../../genkit/bargainChefFlow';

export const config = {
  api: {
    bodyParser: true,
    responseLimit: false,
  },
};

const handleFlow = fetchHandlers([bargainChefFlow], '/api');

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse,
) {
  const host = req.headers.host || 'localhost:3000';
  const url = new URL(req.url || '/', `http://${host}`);
  const headers = new Headers();
  for (const [key, value] of Object.entries(req.headers)) {
    if (value === undefined) continue;
    if (Array.isArray(value)) value.forEach((v) => headers.append(key, v));
    else headers.set(key, String(value));
  }

  const webRequest = new Request(url, {
    method: req.method,
    headers,
    body:
      req.method !== 'GET' && req.method !== 'HEAD'
        ? JSON.stringify(req.body ?? {})
        : undefined,
  });

  const webResponse = await handleFlow(webRequest);
  res.status(webResponse.status);
  webResponse.headers.forEach((value, key) => res.setHeader(key, value));
  if (webResponse.body) {
    Readable.fromWeb(webResponse.body as any).pipe(res);
  } else {
    res.end();
  }
}
