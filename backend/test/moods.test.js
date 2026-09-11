'use strict';

const { test, describe, beforeEach } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const pino = require('pino');
const { createApp } = require('../src/app');
const { loadConfig } = require('../src/config');
const { createMoodsRepository } = require('../src/moods/repository');
const { MOODS } = require('../src/moods/schema');

const USER = { uid: 'user-1', email: 'user@example.com' };
const OTHER = { uid: 'user-2', email: 'other@example.com' };
const ID = '3b241101-e2bb-4255-8caf-4136c566a962';
const AT = '2026-09-11T10:00:00.000Z';

function fakeAuth() {
  return {
    async verifyIdToken(token) {
      if (token === 'u1') return USER;
      if (token === 'u2') return OTHER;
      throw new Error('invalid token');
    },
  };
}

/**
 * Minimal in-memory Firestore: enough of the query builder for the moods
 * repository, so the real repository code is what gets exercised.
 */
function fakeFirestore() {
  const collections = new Map();
  const col = (name) => collections.get(name) ?? collections.set(name, new Map()).get(name);

  class Doc {
    constructor(name, id) {
      this.name = name;
      this.id = id;
    }
    async create(data) {
      if (col(this.name).has(this.id)) throw Object.assign(new Error('already exists'), { code: 6 });
      col(this.name).set(this.id, { ...data, createdAt: new Date() });
    }
    async set(data) {
      col(this.name).set(this.id, { ...data, createdAt: new Date() });
    }
    async update(data) {
      col(this.name).set(this.id, { ...col(this.name).get(this.id), ...data });
    }
    async get() {
      const data = col(this.name).get(this.id);
      return { id: this.id, exists: !!data, data: () => data };
    }
  }

  class Query {
    constructor(name, filters = [], order = null, max = Infinity) {
      Object.assign(this, { name, filters, order, max });
    }
    where(field, op, value) {
      return new Query(this.name, [...this.filters, { field, op, value }], this.order, this.max);
    }
    orderBy(field, dir) {
      return new Query(this.name, this.filters, { field, dir }, this.max);
    }
    limit(n) {
      return new Query(this.name, this.filters, this.order, n);
    }
    async get() {
      const cmp = { '==': (a, b) => a === b, '>=': (a, b) => a >= b, '<=': (a, b) => a <= b };
      const norm = (v) => (v?.toDate ? v.toDate().getTime() : v instanceof Date ? v.getTime() : v);
      let docs = [...col(this.name).entries()].filter(([, d]) =>
        this.filters.every((f) => cmp[f.op](norm(d[f.field]), norm(f.value))),
      );
      if (this.order) {
        docs.sort(([, a], [, b]) => (norm(a[this.order.field]) - norm(b[this.order.field])) * (this.order.dir === 'desc' ? -1 : 1));
      }
      docs = docs.slice(0, this.max);
      return { docs: docs.map(([id, d]) => ({ id, data: () => d })) };
    }
  }

  return {
    collections,
    collection: (name) => Object.assign(new Query(name), { doc: (id) => new Doc(name, id) }),
  };
}

function buildApp(db) {
  const config = loadConfig({ NODE_ENV: 'test' });
  return createApp({ auth: fakeAuth(), wisps: {}, moods: createMoodsRepository(db), logger: pino({ level: 'silent' }), config });
}

const as = (req, token = 'u1') => req.set('Authorization', `Bearer ${token}`);

describe('POST /api/moods', () => {
  let db;
  beforeEach(() => {
    db = fakeFirestore();
  });

  test('creates a log with the caller as owner and returns 201', async () => {
    const res = await as(request(buildApp(db)).post('/api/moods')).send({ id: ID, mood: 'okay', loggedAt: AT });
    assert.equal(res.status, 201);
    assert.equal(res.body.moodLog.id, ID);
    assert.equal(res.body.moodLog.mood, 'okay');
    assert.equal(res.body.moodLog.loggedAt, AT);
    assert.equal(res.body.moodLog.hasNote, false);
    assert.equal(db.collections.get('mood_logs').get(ID).uid, USER.uid);
  });

  test('is idempotent on id: a replay returns 200 with the same log and writes nothing new', async () => {
    const app = buildApp(db);
    await as(request(app).post('/api/moods')).send({ id: ID, mood: 'okay', loggedAt: AT });
    const replay = await as(request(app).post('/api/moods')).send({ id: ID, mood: 'bright', loggedAt: AT });
    assert.equal(replay.status, 200);
    assert.equal(replay.body.moodLog.mood, 'okay', 'the first write wins');
    assert.equal(db.collections.get('mood_logs').size, 1);
  });

  test('refuses an id that belongs to another user', async () => {
    const app = buildApp(db);
    await as(request(app).post('/api/moods')).send({ id: ID, mood: 'okay', loggedAt: AT });
    const res = await as(request(app).post('/api/moods'), 'u2').send({ id: ID, mood: 'okay', loggedAt: AT });
    assert.equal(res.status, 409);
  });

  test('keeps the note out of mood_logs and in mood_notes', async () => {
    const res = await as(request(buildApp(db)).post('/api/moods')).send({
      id: ID,
      mood: 'low',
      loggedAt: AT,
      note: 'Long day.',
    });
    assert.equal(res.status, 201);
    assert.equal(res.body.moodLog.hasNote, true);
    assert.equal(JSON.stringify(res.body).includes('Long day.'), false, 'note body is never echoed with the rating');
    assert.equal(db.collections.get('mood_logs').get(ID).body, undefined);
    assert.equal(db.collections.get('mood_notes').get(ID).body, 'Long day.');
    assert.equal(db.collections.get('mood_notes').get(ID).uid, USER.uid);
  });

  test('rejects a numeric mood, a bad id and unknown fields', async () => {
    const res = await as(request(buildApp(db)).post('/api/moods')).send({ id: 'nope', mood: 7, loggedAt: AT, score: 5 });
    assert.equal(res.status, 400);
    const fields = res.body.details.map((d) => d.field).sort();
    assert.deepEqual(fields, ['(body)', 'id', 'mood']);
  });

  test('accepts every named state and nothing else', async () => {
    assert.deepEqual(MOODS, ['low', 'flat', 'okay', 'good', 'bright']);
    const res = await as(request(buildApp(db)).post('/api/moods')).send({ id: ID, mood: 'meh', loggedAt: AT });
    assert.equal(res.status, 400);
  });
});

describe('PATCH /api/moods/:id', () => {
  test("changes the mood on the caller's own log", async () => {
    const db = fakeFirestore();
    const app = buildApp(db);
    await as(request(app).post('/api/moods')).send({ id: ID, mood: 'okay', loggedAt: AT });
    const res = await as(request(app).patch(`/api/moods/${ID}`)).send({ mood: 'flat' });
    assert.equal(res.status, 200);
    assert.equal(res.body.moodLog.mood, 'flat');
    assert.equal(db.collections.get('mood_logs').size, 1, 'still one check-in');
  });

  test("answers 404 for another user's log and for an unknown id alike", async () => {
    const db = fakeFirestore();
    const app = buildApp(db);
    await as(request(app).post('/api/moods')).send({ id: ID, mood: 'okay', loggedAt: AT });
    const theirs = await as(request(app).patch(`/api/moods/${ID}`), 'u2').send({ mood: 'flat' });
    const missing = await as(request(app).patch('/api/moods/3b241101-e2bb-4255-8caf-4136c566a999')).send({ mood: 'flat' });
    assert.equal(theirs.status, 404);
    assert.equal(missing.status, 404);
    assert.equal(db.collections.get('mood_logs').get(ID).mood, 'okay');
  });

  test('rejects a non-uuid id and a numeric mood', async () => {
    const app = buildApp(fakeFirestore());
    assert.equal((await as(request(app).patch('/api/moods/nope')).send({ mood: 'flat' })).status, 400);
    assert.equal((await as(request(app).patch(`/api/moods/${ID}`)).send({ mood: 3 })).status, 400);
  });
});

describe('GET /api/moods', () => {
  test("returns only the caller's logs, newest first, within the range", async () => {
    const db = fakeFirestore();
    const app = buildApp(db);
    const ids = ['3b241101-e2bb-4255-8caf-4136c566a901', '3b241101-e2bb-4255-8caf-4136c566a902', '3b241101-e2bb-4255-8caf-4136c566a903'];
    await as(request(app).post('/api/moods')).send({ id: ids[0], mood: 'low', loggedAt: '2026-09-01T10:00:00.000Z' });
    await as(request(app).post('/api/moods')).send({ id: ids[1], mood: 'good', loggedAt: '2026-09-10T10:00:00.000Z' });
    await as(request(app).post('/api/moods'), 'u2').send({ id: ids[2], mood: 'bright', loggedAt: '2026-09-10T11:00:00.000Z' });

    const all = await as(request(app).get('/api/moods'));
    assert.deepEqual(all.body.moods.map((m) => m.mood), ['good', 'low']);

    const ranged = await as(request(app).get('/api/moods?from=2026-09-05T00:00:00Z&to=2026-09-11T00:00:00Z'));
    assert.deepEqual(ranged.body.moods.map((m) => m.id), [ids[1]]);
  });

  test('rejects an inverted range', async () => {
    const res = await as(request(buildApp(fakeFirestore())).get('/api/moods?from=2026-09-11T00:00:00Z&to=2026-09-01T00:00:00Z'));
    assert.equal(res.status, 400);
  });

  test('requires a token', async () => {
    const res = await request(buildApp(fakeFirestore())).get('/api/moods');
    assert.equal(res.status, 401);
  });
});
