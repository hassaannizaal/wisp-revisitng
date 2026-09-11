'use strict';

const { Router } = require('express');
const { HttpError } = require('../middleware/errors');
const { verifyToken } = require('../middleware/auth');
const { createMoodSchema, patchMoodSchema, moodIdSchema, listMoodsQuerySchema } = require('./schema');

const FIRESTORE_FAILED_PRECONDITION = 9;

function formatIssues(error) {
  return error.issues.map((i) => ({ field: i.path.join('.') || '(body)', message: i.message }));
}

/**
 * Spec: docs/screens/05-mood-check-in.md
 * @param {{ auth: object, moods: ReturnType<typeof import('./repository').createMoodsRepository> }} deps
 */
function moodsRouter({ auth, moods }) {
  const router = Router();
  router.use(verifyToken(auth));

  router.get('/', async (req, res) => {
    const query = listMoodsQuerySchema.safeParse(req.query);
    if (!query.success) throw new HttpError(400, 'Invalid query', formatIssues(query.error));

    try {
      res.json({ moods: await moods.listByUser(req.user.uid, query.data) });
    } catch (err) {
      if (err.code === FIRESTORE_FAILED_PRECONDITION) {
        req.log?.error({ err }, 'Firestore index missing for mood_logs query');
        throw new HttpError(503, 'Check-ins are temporarily unavailable: the Firestore index is not deployed yet');
      }
      throw err;
    }
  });

  router.post('/', async (req, res) => {
    const body = createMoodSchema.safeParse(req.body);
    if (!body.success) throw new HttpError(400, 'Validation failed', formatIssues(body.error));

    try {
      const { log, created } = await moods.create(req.user.uid, body.data);
      // A replayed request is a success, not a duplicate — the client can retry freely.
      res.status(created ? 201 : 200).json({ moodLog: log });
    } catch (err) {
      if (err.code === 'ID_CONFLICT') throw new HttpError(409, 'That id is already in use');
      throw err;
    }
  });

  router.patch('/:id', async (req, res) => {
    const id = moodIdSchema.safeParse(req.params.id);
    if (!id.success) throw new HttpError(400, 'Invalid id');
    const body = patchMoodSchema.safeParse(req.body);
    if (!body.success) throw new HttpError(400, 'Validation failed', formatIssues(body.error));

    const log = await moods.updateMood(req.user.uid, id.data, body.data.mood);
    if (!log) throw new HttpError(404, 'No such check-in');
    res.json({ moodLog: log });
  });

  return router;
}

module.exports = { moodsRouter };
