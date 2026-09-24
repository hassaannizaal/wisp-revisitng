'use strict';

const { test, describe } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const pino = require('pino');
const { createApp } = require('../src/app');
const { loadConfig } = require('../src/config');
const { createUsersRepository } = require('../src/users/repository');
const { fakeFirestore, fakeAuth, USERS } = require('./support/fake_firestore');

function buildApp(db = fakeFirestore()) {
  const config = loadConfig({ NODE_ENV: 'test' });
  return createApp({ auth: fakeAuth(), wisps: {}, moods: {}, users: createUsersRepository(db), logger: pino({ level: 'silent' }), config });
}

const as = (req, token = 'u1') => req.set('Authorization', `Bearer ${token}`);

describe('GET /api/me', () => {
  test('a new account has no mode yet and the default water goal', async () => {
    const res = await as(request(buildApp()).get('/api/me'));
    assert.equal(res.status, 200);
    assert.deepEqual(res.body.user, {
      uid: USERS.u1.uid,
      email: USERS.u1.email,
      accountMode: null,
      waterGoalGlasses: 8,
      organization: null,
    });
  });

  test('requires a token', async () => {
    const res = await request(buildApp()).get('/api/me');
    assert.equal(res.status, 401);
  });
});

describe('PUT /api/me', () => {
  test("updates only the caller's profile and returns it", async () => {
    const app = buildApp();
    const res = await as(request(app).put('/api/me')).send({ accountMode: 'independent', waterGoalGlasses: 10 });
    assert.equal(res.status, 200);
    assert.equal(res.body.user.accountMode, 'independent');
    assert.equal(res.body.user.waterGoalGlasses, 10);

    const mine = await as(request(app).get('/api/me'));
    assert.equal(mine.body.user.accountMode, 'independent');
    const theirs = await as(request(app).get('/api/me'), 'u2');
    assert.equal(theirs.body.user.accountMode, null);
  });

  test('a partial update keeps the other fields', async () => {
    const app = buildApp();
    await as(request(app).put('/api/me')).send({ waterGoalGlasses: 6 });
    const res = await as(request(app).put('/api/me')).send({ accountMode: 'organization' });
    assert.equal(res.body.user.waterGoalGlasses, 6);
    assert.equal(res.body.user.accountMode, 'organization');
  });

  for (const [name, body] of [
    ['an empty body', {}],
    ['an unknown mode', { accountMode: 'admin' }],
    ['a goal out of range', { waterGoalGlasses: 21 }],
    ['an unknown field', { organization: 'Acme' }],
  ]) {
    test(`rejects ${name}`, async () => {
      const res = await as(request(buildApp()).put('/api/me')).send(body);
      assert.equal(res.status, 400);
    });
  }
});
