'use strict';

const { HttpError } = require('./errors');

/**
 * Verifies the Firebase ID token sent as `Authorization: Bearer <token>` and
 * attaches the decoded token to `req.user`.
 *
 * @param {{ verifyIdToken(token: string): Promise<object> }} auth firebase-admin Auth (or a test double)
 */
function verifyToken(auth) {
  return async (req, res, next) => {
    const header = req.headers.authorization ?? '';
    if (!header.startsWith('Bearer ')) {
      throw new HttpError(401, 'Unauthorized: No token provided');
    }

    const idToken = header.slice('Bearer '.length).trim();
    try {
      req.user = await auth.verifyIdToken(idToken);
    } catch (err) {
      req.log?.warn({ reason: err.message }, 'Token verification failed');
      throw new HttpError(401, 'Unauthorized: Invalid or expired token');
    }
    next();
  };
}

module.exports = { verifyToken };
