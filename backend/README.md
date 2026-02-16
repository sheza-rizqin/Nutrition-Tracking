# NutriTrack Backend Server

Simple Node.js backend for NutriTrack mobile app synchronization.

## What It Does

- **Sync endpoint** — accepts data from mobile app when online
- **Shared data store** — multiple workers can see the same records
- **Offline-first** — app stores locally and syncs when connected
- **Health check** — `/health` endpoint to verify server is running

## Quick Start

### 1. Install dependencies
```bash
cd backend
npm install
```

### 2. Start the server
```bash
npm start
```

You should see:
```
🍎 NutriTrack server running on http://localhost:3000
📊 Health check: http://localhost:3000/health
```

### 3. Test the connection

From mobile app (when running):
- Open home screen
- Look for **"Synced"** status in the top-right corner
- If you see **"Offline"**, make sure:
  - Backend is running on `http://localhost:3000`
  - Your phone/emulator is on the same network as your laptop
  - Android emulator: use `10.0.2.2:3000` instead of `localhost:3000`

### 4. Access the API

**Test server is running:**
```bash
curl http://localhost:3000/health
```

**Get all records:**
```bash
curl http://localhost:3000/api/records
```

**Get maternal records:**
```bash
curl http://localhost:3000/api/maternal
```

**Add a maternal record:**
```bash
curl -X POST http://localhost:3000/api/maternal \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane","age":28,"hemoglobin":11.2}'
```

## Deploying to Production

For free hosting, try:
- **Replit** (https://replit.com) — free tier, can run Node apps
- **Render** (https://render.com) — free tier with limited hours
- **Railway** (https://railway.app) — pay-as-you-go, very affordable

Update the `_serverUrl` in `lib/database/sync_service.dart` to your deployed server URL.

## Future Improvements

- Add real database (MongoDB, PostgreSQL)
- Add authentication (API keys, JWT)
- Add conflict resolution for simultaneous edits
- Add push notifications when data changes
- Add data export (CSV, PDF)

---

**For support or questions about the sync system, check `lib/database/sync_service.dart`**
