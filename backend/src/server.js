'use strict';

require('dotenv').config({ quiet: true });

const { loadConfig } = require('./config');
const { createLogger } = require('./logger');
const { initFirebase } = require('./firebase');
const { createWispsRepository } = require('./wisps/repository');
const { createApp } = require('./app');

const config = loadConfig();
const logger = createLogger({ level: config.logLevel, pretty: !config.isProduction });

let server;
try {
  const { auth, db } = initFirebase({ ...config.firebase, logger });
  const app = createApp({ auth, wisps: createWispsRepository(db), logger, config });
  server = app.listen(config.port, () => {
    logger.info({ port: config.port, env: config.env }, 'Server exhaling');
  });
} catch (err) {
  logger.fatal({ err }, 'Startup failed');
  process.exit(1);
}

// Let in-flight requests finish before the process exits (Cloud Run / Docker send SIGTERM).
function shutdown(signal) {
  logger.info({ signal }, 'Shutting down');
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(1), 10_000).unref();
}
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('unhandledRejection', (reason) => {
  logger.fatal({ err: reason }, 'Unhandled promise rejection');
  process.exit(1);
});
