'use strict';

const { z } = require('zod');

const LIMITS = { mood: 50, reflection: 2000, listMax: 100, listDefault: 20 };

const createWispSchema = z
  .object({
    mood: z
      .string()
      .trim()
      .min(1, 'mood is required')
      .max(LIMITS.mood, `mood must be at most ${LIMITS.mood} characters`),
    reflection: z
      .string()
      .trim()
      .min(1, 'reflection is required')
      .max(LIMITS.reflection, `reflection must be at most ${LIMITS.reflection} characters`),
  })
  .strict();

const listWispsQuerySchema = z.object({
  limit: z.coerce.number().int().min(1).max(LIMITS.listMax).default(LIMITS.listDefault),
});

module.exports = { createWispSchema, listWispsQuerySchema, LIMITS };
