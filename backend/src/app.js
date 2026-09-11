'use strict';

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const { rateLimit } = require('express-rate-limit');
const { pinoHttp } = require('pino-http');
const { wispsRouter } = require('./wisps/router');
const { notFound, errorHandler } = require('./middleware/errors');

/**
 * Builds the Express app without binding a port, so tests can drive it with
 * supertest and inject doubles for Firebase.
 *
 * @param {object} deps
 * @param {object} deps.auth   firebase-admin Auth (needs `verifyIdToken`)
 * @param {object} deps.wisps  wisps repository (see src/wisps/repository.js)
 * @param {import('pino').Logger} deps.logger
 * @param {ReturnType<typeof import('./config').loadConfig>} deps.config
 */
function createApp({ auth, wisps, logger, config }) {
  const app = express();

  app.disable('x-powered-by');
  if (config.trustProxy) {
    app.set('trust proxy', /^\d+$/.test(config.trustProxy) ? Number(config.trustProxy) : config.trustProxy);
  }

  app.use(helmet());
  app.use(cors({ origin: config.corsOrigins.length ? config.corsOrigins : true }));
  app.use(express.json({ limit: '16kb' }));
  app.use(
    pinoHttp({
      logger,
      autoLogging: { ignore: (req) => req.url === '/health' },
      customLogLevel: (req, res, err) =>
        err || res.statusCode >= 500 ? 'error' : res.statusCode >= 400 ? 'warn' : 'info',
    }),
  );

  app.get('/health', (req, res) => {
    res.json({ status: 'WISP Backend is Zen and Running' });
  });

  app.use(
    '/api',
    rateLimit({
      windowMs: config.rateLimit.windowMs,
      limit: config.rateLimit.max,
      standardHeaders: 'draft-8',
      legacyHeaders: false,
      message: { error: 'Too many requests, please try again later' },
    }),
  );
  app.use('/api/wisps', wispsRouter({ auth, wisps }));

  app.use(notFound);
  app.use(errorHandler);
  return app;
}

module.exports = { createApp };
