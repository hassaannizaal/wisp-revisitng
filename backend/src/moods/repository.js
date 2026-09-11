'use strict';

const { FieldValue, Timestamp } = require('firebase-admin/firestore');

// The rating and the words live in different collections on purpose: an
// admin query reads mood_logs and has no path to mood_notes. Nothing in this
// file joins them for anyone but the owner.
const LOGS = 'mood_logs';
const NOTES = 'mood_notes';

const FIRESTORE_ALREADY_EXISTS = 6;

const toIso = (value) => (value instanceof Timestamp ? value.toDate().toISOString() : (value ?? null));

function toMoodLog(doc) {
  const data = doc.data();
  return {
    id: doc.id,
    mood: data.mood,
    loggedAt: toIso(data.loggedAt),
    createdAt: toIso(data.createdAt),
    hasNote: data.hasNote === true,
  };
}

/**
 * @param {import('firebase-admin/firestore').Firestore} db
 */
function createMoodsRepository(db) {
  const logs = db.collection(LOGS);
  const notes = db.collection(NOTES);

  return {
    /**
     * Idempotent on `id`: a retry after a dropped connection returns the
     * existing log instead of writing a duplicate.
     * @returns {{ log: object, created: boolean }}
     */
    async create(uid, { id, mood, loggedAt, note }) {
      const ref = logs.doc(id);
      try {
        await ref.create({
          uid,
          mood,
          loggedAt: Timestamp.fromDate(new Date(loggedAt)),
          createdAt: FieldValue.serverTimestamp(),
          hasNote: note !== undefined,
        });
      } catch (err) {
        if (err.code !== FIRESTORE_ALREADY_EXISTS) throw err;
        const existing = await ref.get();
        if (existing.data().uid !== uid) {
          const conflict = new Error('mood log id belongs to another user');
          conflict.code = 'ID_CONFLICT';
          throw conflict;
        }
        return { log: toMoodLog(existing), created: false };
      }

      if (note !== undefined) {
        await notes.doc(id).set({ uid, body: note, createdAt: FieldValue.serverTimestamp() });
      }
      return { log: toMoodLog(await ref.get()), created: true };
    },

    /**
     * Changes the mood on the caller's own log (a corrected tap on the same
     * check-in). Returns null when the log does not exist or is not theirs —
     * the two are deliberately indistinguishable to the caller.
     */
    async updateMood(uid, id, mood) {
      const ref = logs.doc(id);
      const snapshot = await ref.get();
      if (!snapshot.exists || snapshot.data().uid !== uid) return null;
      await ref.update({ mood });
      return toMoodLog(await ref.get());
    },

    // Requires the composite index (uid ASC, loggedAt DESC) in firebase/firestore.indexes.json.
    async listByUser(uid, { from, to, limit }) {
      let query = logs.where('uid', '==', uid);
      if (from) query = query.where('loggedAt', '>=', Timestamp.fromDate(new Date(from)));
      if (to) query = query.where('loggedAt', '<=', Timestamp.fromDate(new Date(to)));
      const snapshot = await query.orderBy('loggedAt', 'desc').limit(limit).get();
      return snapshot.docs.map(toMoodLog);
    },
  };
}

module.exports = { createMoodsRepository, LOGS, NOTES };
