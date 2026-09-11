'use strict';

const { test, describe, beforeEach } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const pino = require('pino');
const { createApp } = require('../src/app');
const { loadConfig } = require('../src/config');
const { LIMITS } = require('../src/wisps/schema');

const USER = { uid: 'user-1', email: 'user@example.com' };
const VALID_TOKEN = 'valid-token';

function fakeAuth() {
  return {
    async verifyIdToken(token) {
      if (token === VALID_TOKEN) return USER;
      throw new Error('invalid token');
    },
  };
}

function fakeWisps(seed = []) {
  const store = [...seed];
  let next = 1;
  return {
    store,
    async create(uid, { mood, reflection }) {
      const wisp = { id: `w${next++}`, uid, mood, reflection, createdAt: new Date().toISOString() };
      store.push(wisp);
      return wisp;
    },
    async listByUser(uid, { limit }) {
      return store.filter((w) => w.uid === uid).slice(-limit).reverse();
    },
  };
}

function buildApp({ wisps = fakeWisps(), env = {} } = {}) {
  const config = loadConfig({ NODE_ENV: 'test', ...env });
  return createApp({ auth: fakeAuth(), wisps, logger: pino({ level: 'silent' }), config });
}

const authed = (req) => req.set('Authorization', `Bearer ${VALID_TOKEN}`);

describe('GET /health', () => {
  test('is public and reports the service is up', async () => {
    const res = await request(buildApp()).get('/health');
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, { status: 'WISP Backend is Zen and Running' });
  });

  test('sets security headers and hides the framework', async () => {
    const res = await request(buildApp()).get('/health');
    assert.equal(res.headers['x-powered-by'], undefined);
    assert.equal(res.headers['x-content-type-options'], 'nosniff');
  });
});

describe('authentication', () => {
  test('rejects requests without a bearer token', async () => {
    const res = await request(buildApp()).get('/api/wisps/protected');
    assert.equal(res.status, 401);
    assert.deepEqual(res.body, { error: 'Unauthorized: No token provided' });
  });

  test('rejects an invalid token', async () => {
    const res = await request(buildApp()).get('/api/wisps/protected').set('Authorization', 'Bearer nope');
    assert.equal(res.status, 401);
    assert.deepEqual(res.body, { error: 'Unauthorized: Invalid or expired token' });
  });

  test('accepts a valid token and echoes the caller identity', async () => {
    const res = await authed(request(buildApp()).get('/api/wisps/protected'));
    assert.equal(res.status, 200);
    assert.equal(res.body.uid, USER.uid);
    assert.equal(res.body.email, USER.email);
  });
});

describe('POST /api/wisps', () => {
  let wisps;
  beforeEach(() => {
    wisps = fakeWisps();
  });

  test('saves a wisp for the authenticated user', async () => {
    const res = await authed(request(buildApp({ wisps })).post('/api/wisps')).send({
      mood: '  Zen ',
      reflection: 'Breathing.',
    });
    assert.equal(res.status, 201);
    assert.equal(res.body.message, 'Wisp saved successfully!');
    assert.equal(res.body.wispId, 'w1');
    assert.equal(res.body.wisp.mood, 'Zen', 'input is trimmed');
    assert.equal(wisps.store[0].uid, USER.uid, 'uid comes from the token, never the body');
  });

  test('rejects a missing reflection with field-level details', async () => {
    const res = await authed(request(buildApp({ wisps })).post('/api/wisps')).send({ mood: 'Zen' });
    assert.equal(res.status, 400);
    assert.equal(res.body.error, 'Validation failed');
    assert.deepEqual(res.body.details.map((d) => d.field), ['reflection']);
    assert.equal(wisps.store.length, 0);
  });

  test('rejects oversized and unknown fields', async () => {
    const res = await authed(request(buildApp({ wisps })).post('/api/wisps')).send({
      mood: 'Zen',
      reflection: 'x'.repeat(LIMITS.reflection + 1),
      uid: 'someone-else',
    });
    assert.equal(res.status, 400);
    const fields = res.body.details.map((d) => d.field).sort();
    assert.deepEqual(fields, ['(body)', 'reflection']);
  });

  test('rejects malformed JSON', async () => {
    const res = await authed(request(buildApp({ wisps })).post('/api/wisps'))
      .set('Content-Type', 'application/json')
      .send('{"mood": ');
    assert.equal(res.status, 400);
    assert.equal(res.body.error, 'Malformed JSON body');
  });
});

describe('GET /api/wisps', () => {
  test('lists only the caller\'s wisps, newest first, honouring limit', async () => {
    const wisps = fakeWisps([
      { id: 'a', uid: USER.uid, mood: 'Calm', reflection: 'one', createdAt: null },
      { id: 'b', uid: 'someone-else', mood: 'Tense', reflection: 'two', createdAt: null },
      { id: 'c', uid: USER.uid, mood: 'Zen', reflection: 'three', createdAt: null },
    ]);
    const res = await authed(request(buildApp({ wisps })).get('/api/wisps?limit=1'));
    assert.equal(res.status, 200);
    assert.deepEqual(res.body.wisps.map((w) => w.id), ['c']);
  });

  test('rejects an out-of-range limit', async () => {
    const res = await authed(request(buildApp()).get(`/api/wisps?limit=${LIMITS.listMax + 1}`));
    assert.equal(res.status, 400);
    assert.equal(res.body.error, 'Invalid query');
  });

  test('reports a missing Firestore index as 503 instead of 500', async () => {
    const wisps = {
      async listByUser() {
        throw Object.assign(new Error('9 FAILED_PRECONDITION: The query requires an index.'), { code: 9 });
      },
    };
    const res = await authed(request(buildApp({ wisps })).get('/api/wisps'));
    assert.equal(res.status, 503);
    assert.match(res.body.error, /index/);
  });
});

describe('errors and limits', () => {
  test('unknown routes return a JSON 404', async () => {
    const res = await request(buildApp()).get('/nope');
    assert.equal(res.status, 404);
    assert.match(res.body.error, /Route not found/);
  });

  test('unexpected failures never leak internals', async () => {
    const wisps = {
      async create() {
        throw new Error('secret database detail');
      },
    };
    const res = await authed(request(buildApp({ wisps })).post('/api/wisps')).send({ mood: 'Zen', reflection: 'x' });
    assert.equal(res.status, 500);
    assert.deepEqual(res.body, { error: 'Internal Server Error' });
  });

  test('rate limiting kicks in after the configured number of requests', async () => {
    const app = buildApp({ env: { RATE_LIMIT_MAX: '2' } });
    await authed(request(app).get('/api/wisps/protected'));
    await authed(request(app).get('/api/wisps/protected'));
    const res = await authed(request(app).get('/api/wisps/protected'));
    assert.equal(res.status, 429);
    assert.deepEqual(res.body, { error: 'Too many requests, please try again later' });
  });
});

describe('config', () => {
  test('rejects an invalid PORT with a readable message', () => {
    assert.throws(() => loadConfig({ PORT: 'abc' }), /Invalid environment configuration: PORT/);
  });

  test('parses a CORS allow-list', () => {
    const config = loadConfig({ CORS_ORIGINS: 'https://a.example, https://b.example' });
    assert.deepEqual(config.corsOrigins, ['https://a.example', 'https://b.example']);
  });
});
