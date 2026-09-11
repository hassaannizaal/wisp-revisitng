'use strict';

const { z } = require('zod');

// Five named states, never a number (design rule 6). Order runs low → bright.
const MOODS = ['low', 'flat', 'okay', 'good', 'bright'];

const LIMITS = { note: 2000, listMax: 200, listDefault: 60 };

const createMoodSchema = z
  .object({
    // Client-generated so a write works offline and a retry is a no-op.
    id: z.uuid(),
    mood: z.enum(MOODS),
    loggedAt: z.iso.datetime({ offset: true }),
    note: z.string().trim().min(1).max(LIMITS.note).optional(),
  })
  .strict();

const patchMoodSchema = z.object({ mood: z.enum(MOODS) }).strict();

const moodIdSchema = z.uuid();

const listMoodsQuerySchema = z
  .object({
    from: z.iso.datetime({ offset: true }).optional(),
    to: z.iso.datetime({ offset: true }).optional(),
    limit: z.coerce.number().int().min(1).max(LIMITS.listMax).default(LIMITS.listDefault),
  })
  .refine((q) => !q.from || !q.to || new Date(q.from) <= new Date(q.to), {
    message: 'from must be before to',
    path: ['from'],
  });

module.exports = { MOODS, LIMITS, createMoodSchema, patchMoodSchema, moodIdSchema, listMoodsQuerySchema };
