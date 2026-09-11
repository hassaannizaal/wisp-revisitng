'use strict';

/** An error whose status code and message are safe to send to the client. */
class HttpError extends Error {
  constructor(status, message, details) {
    super(message);
    this.name = 'HttpError';
    this.status = status;
    if (details !== undefined) this.details = details;
  }
}

function notFound(req, res) {
  res.status(404).json({ error: `Route not found: ${req.method} ${req.originalUrl}` });
}

// Express 5 forwards rejected promises here automatically, so route handlers
// never need their own try/catch just to reach this function.
function errorHandler(err, req, res, next) {
  const isHttpError = err instanceof HttpError;
  const status = isHttpError ? err.status : (err.status ?? err.statusCode ?? 500);

  if (status >= 500) req.log?.error({ err }, 'Request failed');
  else req.log?.warn({ err: { message: err.message, status } }, 'Request rejected');

  let message;
  if (isHttpError) message = err.message;
  else if (err.type === 'entity.parse.failed') message = 'Malformed JSON body'; // express.json()
  else if (status >= 500) message = 'Internal Server Error'; // never leak internals
  else message = err.message; // other body-parser errors, e.g. 413 payload too large

  res.status(status).json({ error: message, ...(err.details ? { details: err.details } : {}) });
}

module.exports = { HttpError, notFound, errorHandler };
