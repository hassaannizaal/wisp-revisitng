'use strict';

const { z } = require('zod');

/**
 * Runtime configuration, validated once at startup so a bad deployment fails
 * fast with a readable message instead of misbehaving at request time.
 */
const csv = z
  .string()
  .optional()
  .transform((value) =>
    (value ?? '')
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean),
  );

const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().min(0).max(65535).default(5000),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent']).optional(),
  // Comma-separated allow-list, e.g. "https://app.example.com,https://admin.example.com".
  // Empty (the default) reflects any origin, which is what local development needs.
  CORS_ORIGINS: csv,
  // Set to "1" (or a hop count) when running behind a reverse proxy / Cloud Run so
  // rate limiting sees the real client IP.
  TRUST_PROXY: z.string().optional(),
  RATE_LIMIT_WINDOW_MS: z.coerce.number().int().positive().default(15 * 60 * 1000),
  RATE_LIMIT_MAX: z.coerce.number().int().positive().default(100),
  // Optional overrides for Firebase credentials; see src/firebase.js.
  FIREBASE_SERVICE_ACCOUNT_PATH: z.string().optional(),
  FIREBASE_PROJECT_ID: z.string().optional(),
});

function loadConfig(env = process.env) {
  const result = schema.safeParse(env);
  if (!result.success) {
    const details = result.error.issues.map((i) => `${i.path.join('.')}: ${i.message}`).join('; ');
    throw new Error(`Invalid environment configuration: ${details}`);
  }
  const c = result.data;
  return {
    env: c.NODE_ENV,
    isProduction: c.NODE_ENV === 'production',
    port: c.PORT,
    logLevel: c.LOG_LEVEL ?? (c.NODE_ENV === 'test' ? 'silent' : 'info'),
    corsOrigins: c.CORS_ORIGINS,
    trustProxy: c.TRUST_PROXY,
    rateLimit: { windowMs: c.RATE_LIMIT_WINDOW_MS, max: c.RATE_LIMIT_MAX },
    firebase: { serviceAccountPath: c.FIREBASE_SERVICE_ACCOUNT_PATH, projectId: c.FIREBASE_PROJECT_ID },
  };
}

module.exports = { loadConfig };
