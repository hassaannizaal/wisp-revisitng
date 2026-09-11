'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { initializeApp, getApps, cert, applicationDefault } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');

const DEFAULT_KEY_PATH = path.join(__dirname, '..', 'serviceAccountKey.json');

/**
 * Resolves credentials in order of preference:
 *   1. A service-account JSON file (backend/serviceAccountKey.json, or FIREBASE_SERVICE_ACCOUNT_PATH)
 *   2. Application Default Credentials (GOOGLE_APPLICATION_CREDENTIALS, or the runtime identity on
 *      Cloud Run / GCE / GKE), which is the recommended way to deploy without shipping key files.
 */
function resolveCredential({ serviceAccountPath, logger }) {
  const keyPath = serviceAccountPath ?? DEFAULT_KEY_PATH;
  if (fs.existsSync(keyPath)) {
    logger.info({ keyPath }, 'Firebase: using service account key file');
    return cert(keyPath);
  }
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS || process.env.K_SERVICE || process.env.GAE_SERVICE) {
    logger.info('Firebase: using Application Default Credentials');
    return applicationDefault();
  }
  throw new Error(
    `Firebase credentials not found. Either place a service account key at ${keyPath} ` +
      '(Firebase console → Project settings → Service accounts → Generate new private key), ' +
      'or set GOOGLE_APPLICATION_CREDENTIALS. See README.md.',
  );
}

function initFirebase({ serviceAccountPath, projectId, logger }) {
  const app =
    getApps()[0] ??
    initializeApp({
      credential: resolveCredential({ serviceAccountPath, logger }),
      ...(projectId ? { projectId } : {}),
    });
  return { auth: getAuth(app), db: getFirestore(app) };
}

module.exports = { initFirebase };
