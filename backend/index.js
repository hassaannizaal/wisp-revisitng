const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin (Ensure you have a service account key)
admin.initializeApp({
    credential: admin.credential.applicationDefault(), // or point to your JSON key
});

// Basic Health Check Route
app.get('/health', (req, res) => {
    res.status(200).send({ status: 'WISP Backend is Zen and Running' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🚀 Server exhaling on port ${PORT}`);
});