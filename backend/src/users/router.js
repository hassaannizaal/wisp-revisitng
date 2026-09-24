'use strict';

const { Router } = require('express');
const { HttpError } = require('../middleware/errors');
const { verifyToken } = require('../middleware/auth');
const { updateMeSchema } = require('./schema');

function formatIssues(error) {
  return error.issues.map((i) => ({ field: i.path.join('.') || '(body)', message: i.message }));
}

/**
 * The signed-in user's own profile. Spec: docs/screens/03-account-mode.md
 * @param {{ auth: object, users: ReturnType<typeof import('./repository').createUsersRepository> }} deps
 */
function usersRouter({ auth, users }) {
  const router = Router();
  router.use(verifyToken(auth));

  router.get('/', async (req, res) => {
    res.json({ user: await users.get(req.user.uid, req.user.email) });
  });

  router.put('/', async (req, res) => {
    const body = updateMeSchema.safeParse(req.body);
    if (!body.success) throw new HttpError(400, 'Validation failed', formatIssues(body.error));
    res.json({ user: await users.update(req.user.uid, req.user.email, body.data) });
  });

  return router;
}

module.exports = { usersRouter };
