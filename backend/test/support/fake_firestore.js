'use strict';

/**
 * Minimal in-memory Firestore: enough of the document and query API for the
 * repositories, so the real repository code is what gets exercised in tests.
 */
function fakeFirestore() {
  const collections = new Map();
  const col = (name) => collections.get(name) ?? collections.set(name, new Map()).get(name);
  const norm = (v) => (v?.toDate ? v.toDate().getTime() : v instanceof Date ? v.getTime() : v);

  class Doc {
    constructor(name, id) {
      this.name = name;
      this.id = id;
    }
    async create(data) {
      if (col(this.name).has(this.id)) throw Object.assign(new Error('already exists'), { code: 6 });
      col(this.name).set(this.id, { ...data, createdAt: new Date() });
    }
    async set(data, options = {}) {
      const previous = options.merge ? col(this.name).get(this.id) ?? {} : {};
      col(this.name).set(this.id, { ...previous, ...data, createdAt: previous.createdAt ?? new Date() });
    }
    async update(data) {
      if (!col(this.name).has(this.id)) throw Object.assign(new Error('not found'), { code: 5 });
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
    orderBy(field, dir = 'asc') {
      return new Query(this.name, this.filters, { field, dir }, this.max);
    }
    limit(n) {
      return new Query(this.name, this.filters, this.order, n);
    }
    async get() {
      const cmp = {
        '==': (a, b) => a === b,
        '>=': (a, b) => a >= b,
        '<=': (a, b) => a <= b,
        '>': (a, b) => a > b,
        '<': (a, b) => a < b,
      };
      let docs = [...col(this.name).entries()].filter(([, d]) =>
        this.filters.every((f) => cmp[f.op](norm(d[f.field]), norm(f.value))),
      );
      if (this.order) {
        const sign = this.order.dir === 'desc' ? -1 : 1;
        docs.sort(([, a], [, b]) => {
          const x = norm(a[this.order.field]);
          const y = norm(b[this.order.field]);
          return (x < y ? -1 : x > y ? 1 : 0) * sign;
        });
      }
      docs = docs.slice(0, this.max);
      return { docs: docs.map(([id, d]) => ({ id, data: () => d })), size: docs.length };
    }
  }

  return {
    collections,
    collection: (name) => Object.assign(new Query(name), { doc: (id) => new Doc(name, id) }),
  };
}

const USERS = {
  u1: { uid: 'user-1', email: 'user@example.com' },
  u2: { uid: 'user-2', email: 'other@example.com' },
};

function fakeAuth() {
  return {
    async verifyIdToken(token) {
      if (USERS[token]) return USERS[token];
      throw new Error('invalid token');
    },
  };
}

module.exports = { fakeFirestore, fakeAuth, USERS };
