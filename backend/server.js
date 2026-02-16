const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// In-memory store (replace with real DB for production)
let maternalRecords = [];
let childRecords = [];
let growthMeasurements = [];

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ============ MATERNAL RECORDS ============

// Get all maternal records
app.get('/api/maternal', (req, res) => {
  res.json(maternalRecords);
});

// Get single maternal record
app.get('/api/maternal/:id', (req, res) => {
  const record = maternalRecords.find(r => r.id === parseInt(req.params.id));
  if (record) {
    res.json(record);
  } else {
    res.status(404).json({ error: 'Record not found' });
  }
});

// Create maternal record
app.post('/api/maternal', (req, res) => {
  const record = req.body;
  record.id = Date.now(); // simple ID generation
  record.server_synced_at = new Date().toISOString();
  maternalRecords.push(record);
  res.status(201).json(record);
});

// Update maternal record (by ID, last write wins)
app.put('/api/maternal/:id', (req, res) => {
  const idx = maternalRecords.findIndex(r => r.id === parseInt(req.params.id));
  if (idx !== -1) {
    const updated = { ...req.body, id: parseInt(req.params.id), server_synced_at: new Date().toISOString() };
    maternalRecords[idx] = updated;
    res.json(updated);
  } else {
    res.status(404).json({ error: 'Record not found' });
  }
});

// ============ CHILD RECORDS ============

// Get all child records
app.get('/api/child', (req, res) => {
  res.json(childRecords);
});

// Get single child record
app.get('/api/child/:id', (req, res) => {
  const record = childRecords.find(r => r.id === parseInt(req.params.id));
  if (record) {
    res.json(record);
  } else {
    res.status(404).json({ error: 'Record not found' });
  }
});

// Create child record
app.post('/api/child', (req, res) => {
  const record = req.body;
  record.id = Date.now();
  record.server_synced_at = new Date().toISOString();
  childRecords.push(record);
  res.status(201).json(record);
});

// Update child record
app.put('/api/child/:id', (req, res) => {
  const idx = childRecords.findIndex(r => r.id === parseInt(req.params.id));
  if (idx !== -1) {
    const updated = { ...req.body, id: parseInt(req.params.id), server_synced_at: new Date().toISOString() };
    childRecords[idx] = updated;
    res.json(updated);
  } else {
    res.status(404).json({ error: 'Record not found' });
  }
});

// ============ GROWTH MEASUREMENTS ============

// Get all growth measurements
app.get('/api/growth', (req, res) => {
  res.json(growthMeasurements);
});

// Create growth measurement
app.post('/api/growth', (req, res) => {
  const record = req.body;
  record.id = Date.now();
  record.server_synced_at = new Date().toISOString();
  growthMeasurements.push(record);
  res.status(201).json(record);
});

// ============ BULK SYNC ============

// Sync endpoint: returns all records
app.get('/api/records', (req, res) => {
  res.json({
    maternal: maternalRecords,
    child: childRecords,
    growth: growthMeasurements,
    synced_at: new Date().toISOString(),
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🍎 NutriTrack server running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`📋 API endpoints:`);
  console.log(`   GET  /api/maternal      - Get all maternal records`);
  console.log(`   POST /api/maternal      - Create maternal record`);
  console.log(`   GET  /api/child         - Get all child records`);
  console.log(`   POST /api/child         - Create child record`);
  console.log(`   GET  /api/records       - Sync all records`);
});
