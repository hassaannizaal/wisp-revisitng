const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin with the Service Account
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Initialize Firestore
const db = admin.firestore();

// ==========================================
// 🛡️ THE SECURITY GUARD (Auth Middleware)
// ==========================================
const verifyToken = async (req, res, next) => {
    const authHeader = req.headers.authorization;

    // 1. Check if the token was even sent
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Unauthorized: No token provided' });
    }

    // 2. Extract the token string
    const idToken = authHeader.split('Bearer ')[1];

    try {
        // 3. Verify the token with Firebase Admin
        const decodedToken = await admin.auth().verifyIdToken(idToken);

        // 4. Attach the user's UID to the request so the next function knows who called it
        req.user = decodedToken;
        next(); // Let the request proceed to the actual route!

    } catch (error) {
        console.error('Token Verification Failed:', error.message);
        return res.status(401).json({ error: 'Unauthorized: Invalid or expired token' });
    }
};

// ==========================================
// 📍 ROUTES
// ==========================================

// Public Route (Anyone can access)
app.get('/health', (req, res) => {
    res.status(200).send({ status: 'WISP Backend is Zen and Running' });
});

// Protected Route (ONLY logged-in users can access)
// Notice how we pass `verifyToken` before the final (req, res) function
app.get('/api/wisps/protected', verifyToken, (req, res) => {
    res.status(200).send({
        message: 'Welcome to the Deep Room. Your token is valid.',
        uid: req.user.uid,
        email: req.user.email
    });
});

// The First Real Endpoint: Saving a Wisp
app.post('/api/wisps', verifyToken, async (req, res) => {
    try {
        // Extract the data sent from the Flutter frontend
        const { mood, reflection } = req.body;
        
        // Extract the secure UID provided by our Auth Middleware
        const uid = req.user.uid;

        // Create a new document in the "wisps" Firestore collection
        const wispRef = await db.collection('wisps').add({
            uid: uid,
            mood: mood,
            reflection: reflection,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        });

        // Send a success response back to Flutter
        res.status(201).json({ 
            message: 'Wisp saved successfully!', 
            wispId: wispRef.id 
        });
        
    } catch (error) {
        console.error('Error saving wisp:', error);
        res.status(500).json({ error: 'Failed to save Wisp' });
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🚀 Server exhaling on port ${PORT}`);
});