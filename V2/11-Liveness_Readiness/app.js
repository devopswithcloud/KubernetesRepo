const express = require('express');
const app = express();

let alive = true;

//Root route
app.get('/', (req, res) => {
    res.send('Hello, from Liveness and Readiness Probe Example!');
});

// LIVENESS
app.get('/live', (req, res) => {
    if (!alive) return res.status(500).send('NOT OK');
    res.status(200).send('OK');
});

// Readiness
app.get('/ready', (req, res) => {
    res.status(200).send('READY');
});

// Health check route
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});