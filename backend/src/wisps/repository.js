'use strict';

const { FieldValue } = require('firebase-admin/firestore');

const COLLECTION = 'wisps';

function toWisp(doc) {
  const data = doc.data();
  return {
    id: doc.id,
    uid: data.uid,
    mood: data.mood,
    reflection: data.reflection,
    // Server timestamps are null until the write is committed; guard anyway.
    createdAt: data.createdAt?.toDate ? data.createdAt.toDate().toISOString() : null,
  };
}

/**
 * All Firestore access for wisps lives here so the HTTP layer stays free of
 * database details and can be tested with an in-memory double.
 *
 * @param {import('firebase-admin/firestore').Firestore} db
 */
function createWispsRepository(db) {
  const collection = db.collection(COLLECTION);

  return {
    async create(uid, { mood, reflection }) {
      const ref = await collection.add({ uid, mood, reflection, createdAt: FieldValue.serverTimestamp() });
      return toWisp(await ref.get());
    },

    // Requires the composite index (uid ASC, createdAt DESC) declared in
    // firebase/firestore.indexes.json.
    async listByUser(uid, { limit }) {
      const snapshot = await collection.where('uid', '==', uid).orderBy('createdAt', 'desc').limit(limit).get();
      return snapshot.docs.map(toWisp);
    },
  };
}

module.exports = { createWispsRepository, COLLECTION };
