# Quick Start Guide - Backend & Frontend Integration

## 🚀 Getting Started in 5 Minutes

### Prerequisites
- Python 3.13+
- Flutter 3.9+
- Git

---

## Step 1: Start the Backend

```powershell
# Navigate to backend
cd backend/Backend

# Install dependencies (if not already done)
pip install -r requirements.txt

# Initialize database
python init_db.py

# Start the server
python main.py
```

✅ **Backend running on:** `http://localhost:8000`
✅ **API docs available at:** `http://localhost:8000/docs`

---

## Step 2: Start the Flutter App

```bash
# Navigate to frontend
cd ui/myapp

# Get dependencies
flutter pub get

# Run the app
flutter run

# Or run on web
flutter run -d web
```

✅ **App will connect to backend automatically**

---

## Step 3: Test the Integration

### Test Timetable Page
1. Open the app → Navigate to **Timetable** tab
2. Should show generated classes from backend
3. Click refresh icon to reload data

### Test Seating Page (NEW)
1. Navigate to **Seating** tab
2. Select exam date from dropdown
3. Click "Fetch Available Rooms"
4. Click "Generate Seating" to create arrangements
5. View room occupancy with color indicators

### Test Occupancy Page
1. Navigate to **Occupancy** tab
2. View lab and classroom occupancy
3. Click refresh icon to update data

---

## API Configuration

**File:** `lib/services/api_client.dart`

Default:
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

### For Different Hosts
```dart
// Local development
static const String baseUrl = 'http://localhost:8000/api';

// Remote server
static const String baseUrl = 'http://your-server.com:8000/api';

// Docker container
static const String baseUrl = 'http://backend-service:8000/api';
```

---

## Key Features Integrated

### ✅ Timetable Integration
- Fetches from `/api/timetable/generate_timetable`
- Displays dynamic class schedule
- Refresh functionality
- Error handling

### ✅ Seating Integration
- Lists all exams from `/api/seating/v1/exams`
- Fetches available rooms from `/api/seating/v1/seating/available-rooms`
- Generates seating from `/api/seating/v1/seating/generate`
- Color-coded room capacity (Green/Orange/Red)

### ✅ Occupancy Integration
- Real-time room data from `/api/seating/v1/rooms/`
- Lab vs Classroom filtering
- Occupancy percentage calculation
- Status indicators

### ✅ Navigation
- Updated `prof_shell.dart` with 6 tabs
- Added Seating tab with icon
- Persistent state between tabs

---

## Common Commands

### Backend
```powershell
# Start server
python main.py

# View API docs
# Open browser: http://localhost:8000/docs

# Check health
# Open browser: http://localhost:8000/health

# Initialize database
python init_db.py
```

### Frontend
```bash
# Get dependencies
flutter pub get

# Run on device
flutter run

# Run on web
flutter run -d web

# Build APK
flutter build apk

# Clean and rebuild
flutter clean && flutter pub get && flutter run
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `Connection refused` | Ensure backend is running on port 8000 |
| `No classes displayed` | Check backend has timetable data |
| `Empty seating list` | Create exams in backend first |
| `API timeout` | Check network connectivity |
| `Null pointer exception` | Clear app cache and reinstall |

---

## Project Structure

```
frontend/
├── backend/
│   └── Backend/
│       ├── main.py              # FastAPI server
│       ├── init_db.py           # Database init
│       └── appseating/          # Main app
├── ui/
│   └── myapp/                   # Flutter app
│       ├── lib/
│       │   ├── services/        # API services (NEW)
│       │   ├── seating_page.dart (NEW)
│       │   ├── timetable_page.dart (updated)
│       │   ├── occupancy_page.dart (updated)
│       │   └── prof_shell.dart (updated)
│       └── pubspec.yaml         # Dependencies (updated)
└── INTEGRATION_GUIDE.md         # Full guide (NEW)
```

---

## What's New?

### Added Files
- `lib/services/api_client.dart` - HTTP client
- `lib/services/seating_service.dart` - Seating APIs
- `lib/services/timetable_service.dart` - Timetable APIs
- `lib/services/occupancy_service.dart` - Occupancy APIs
- `lib/seating_page.dart` - Seating arrangement UI
- `INTEGRATION_GUIDE.md` - Complete integration docs

### Updated Files
- `lib/timetable_page.dart` - Added API integration
- `lib/occupancy_page.dart` - Added API integration
- `lib/prof_shell.dart` - Added seating navigation
- `pubspec.yaml` - Added Dio & Provider packages

---

## Next Steps

1. ✅ Verify backend is running
2. ✅ Verify frontend can connect
3. ✅ Test all three pages (Timetable, Seating, Occupancy)
4. 🔜 Integrate authentication
5. 🔜 Add offline caching
6. 🔜 Implement real-time updates

---

## Support

### Backend Documentation
Open: `http://localhost:8000/docs`

### API Endpoints
See `backend/Backend/API_ENDPOINTS.md`

### Integration Details
See `INTEGRATION_GUIDE.md`

---

**Status:** ✅ Ready to Use
**Last Updated:** November 28, 2025
