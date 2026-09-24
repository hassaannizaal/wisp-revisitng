'use strict';

const { FieldValue } = require('firebase-admin/firestore');
const { WATER_GOAL } = require('./schema');

const COLLECTION = 'users';

function toUser(uid, email, data = {}) {
  return {
    uid,
    email,
    // null until the account-mode screen has been completed (spec 03).
    accountMode: data.accountMode ?? null,
    waterGoalGlasses: data.waterGoalGlasses ?? WATER_GOAL.default,
    // Organization membership is not designed yet; nothing can grant it.
    organization: null,
  };
}

/**
 * @param {import('firebase-admin/firestore').Firestore} db
 */
function createUsersRepository(db) {
  const users = db.collection(COLLECTION);

  return {
    async get(uid, email) {
      const snapshot = await users.doc(uid).get();
      return toUser(uid, email, snapshot.exists ? snapshot.data() : {});
    },

    async update(uid, email, fields) {
      await users.doc(uid).set({ ...fields, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
      return this.get(uid, email);
    },
  };
}

module.exports = { createUsersRepository, COLLECTION };
