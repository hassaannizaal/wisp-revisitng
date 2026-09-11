'use strict';

const pino = require('pino');

function createLogger({ level, pretty }) {
  return pino({
    level,
    // Never let a bearer token reach the logs, even at trace level.
    redact: { paths: ['req.headers.authorization'], censor: '[REDACTED]' },
    ...(pretty ? { transport: { target: 'pino-pretty', options: { colorize: true } } } : {}),
  });
}

module.exports = { createLogger };
