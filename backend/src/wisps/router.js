'use strict';

const { Router } = require('express');
const { HttpError } = require('../middleware/errors');
const { verifyToken } = require('../middleware/auth');
const { createWispSchema, listWispsQuerySchema } = require('./schema');

// gRPC status 9 = FAILED_PRECONDITION, which Firestore uses for a missing composite index.
const FIRESTORE_FAILED_PRECONDITION = 9;

function formatIssues(error) {
  return error.issues.map((i) => ({ field: i.path.join('.') || '(body)', message: i.message }));
}

/**
 * @param {{ auth: object, wisps: ReturnType<typeof import('./repository').createWispsRepository> }} deps
 */
function wispsRouter({ auth, wisps }) {
  const router = Router();
  router.use(verifyToken(auth));

  // Kept for the connection self-test button in the app.
  router.get('/protected', (req, res) => {
    res.json({ message: 'Welcome to the Deep Room. Your token is valid.', uid: req.user.uid, email: req.user.email });
  });

  router.get('/', async (req, res) => {
    const query = listWispsQuerySchema.safeParse(req.query);
    if (!query.success) throw new HttpError(400, 'Invalid query', formatIssues(query.error));

    try {
      const items = await wisps.listByUser(req.user.uid, query.data);
      res.json({ wisps: items });
    } catch (err) {
      if (err.code === FIRESTORE_FAILED_PRECONDITION) {
        req.log?.error({ err }, 'Firestore index missing for wisps list query');
        throw new HttpError(503, 'Wisps are temporarily unavailable: the Firestore index is not deployed yet');
      }
      throw err;
    }
  });

  router.post('/', async (req, res) => {
    const body = createWispSchema.safeParse(req.body);
    if (!body.success) throw new HttpError(400, 'Validation failed', formatIssues(body.error));

    const wisp = await wisps.create(req.user.uid, body.data);
    res.status(201).json({ message: 'Wisp saved successfully!', wispId: wisp.id, wisp });
  });

  return router;
}

module.exports = { wispsRouter };
