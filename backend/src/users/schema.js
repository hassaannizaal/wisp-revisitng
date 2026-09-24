'use strict';

const { z } = require('zod');

const ACCOUNT_MODES = ['independent', 'organization'];
const WATER_GOAL = { min: 1, max: 20, default: 8 };

const updateMeSchema = z
  .object({
    accountMode: z.enum(ACCOUNT_MODES).optional(),
    waterGoalGlasses: z.number().int().min(WATER_GOAL.min).max(WATER_GOAL.max).optional(),
  })
  .strict()
  .refine((body) => Object.keys(body).length > 0, { message: 'nothing to update' });

module.exports = { ACCOUNT_MODES, WATER_GOAL, updateMeSchema };
