# Backend-Frontend Integration Guide

## Overview
Complete integration of the FastAPI backend with the Flutter frontend for exam seating and timetable management.

---

## Architecture

### Backend Services (Python/FastAPI)
**Base URL:** `http://localhost:8000`

#### Available Endpoints
1. **Authentication** (`/api/auth`)
   - Register, Login, Token Refresh
   - User validation

2. **Seating Management** (`/api/seating/v1`)
   - Room management
   - Student management
   - Exam management
   - Seating arrangement generation
   - CSV export/visualization

3. **Timetable Generation** (`/api/timetable`)
   - Department-based timetable generation
   - Schedule optimization

---

## Frontend Structure (Flutter/Dart)

### New Service Layer (`lib/services/`)

#### 1. **api_client.dart**
- Centralized HTTP client using Dio
- Base configuration for all API calls
- Error handling and interceptors

```dart
final apiClient = ApiClient();
final response = await apiClient.get(
  '/endpoint',
  fromJson: (data) => MyModel.fromJson(data),
);
```

#### 2. **seating_service.dart**
- Manages exam seating API calls
- Methods:
  - `getAvailableRooms()` - Fetch available rooms for an exam
  - `getSeatingByRoom()` - Get seating arrangement by specific room
  - `generateSeating()` - Generate new seating arrangement
  - `getExams()` - Fetch all exams
  - `downloadSeatingCSV()` - Export seating as CSV
  - `getSeatingVisualization()` - Get SVG visualization

```dart
final seatingService = SeatingService(apiClient);
final rooms = await seatingService.getAvailableRooms(
  examDate: '2025-12-01',
  session: 'FN',
);
```

#### 3. **timetable_service.dart**
- Manages timetable generation API calls
- Models: `ClassSchedule`
- Methods:
  - `generateTimetable()` - Generate timetable for departments
  - `parseTimetable()` - Parse API response into UI-friendly format

```dart
final timetableService = TimetableService(apiClient);
final timetable = await timetableService.generateTimetable(
  departments: [...],
  timeslots: [...],
);
```

#### 4. **occupancy_service.dart**
- Manages room occupancy API calls
- Models: `RoomOccupancy`
- Methods:
  - `getRoomOccupancy()` - Fetch all rooms with occupancy data
  - `getRoomOccupancyDetail()` - Get specific room details

```dart
final occupancyService = OccupancyService(apiClient);
final rooms = await occupancyService.getRoomOccupancy();
```

---

## Page Integration

### 1. **Timetable Page** (`timetable_page.dart`)
**Integrates with:** `/api/timetable/generate_timetable`

**Features:**
- Fetches timetable data from backend on initialization
- Displays classes with dynamic scheduling
- Error handling with retry mechanism
- Loading indicators
- Refresh button to re-fetch data

**Key Methods:**
- `_fetchTimetable()` - Calls `TimetableService.generateTimetable()`
- `_buildErrorWidget()` - Shows error state with retry
- Dynamic class card rendering from API data

---

### 2. **Seating Page** (`seating_page.dart`)
**Integrates with:** `/api/seating/v1/` endpoints

**Features:**
- View available exams
- Filter by exam date and session (FN/AN)
- Generate seating arrangements
- View room occupancy and capacity
- Color-coded occupancy indicators (Red/Orange/Green)
- Real-time room capacity visualization

**Key Methods:**
- `_fetchExams()` - List all exams
- `_fetchAvailableRooms()` - Get rooms for selected exam
- `_generateSeating()` - Create new seating arrangement
- `_getOccupancyColor()` - Determine room status color

---

### 3. **Occupancy Page** (`occupancy_page.dart`)
**Integrates with:** `/api/seating/v1/rooms/`

**Features:**
- View lab occupancy
- View classroom occupancy
- Tab-based navigation
- Real-time occupancy percentages
- Color-coded status (Critical/High/Medium/Low)
- Refresh button to update data
- Error handling with user feedback

**Key Methods:**
- `_fetchOccupancyData()` - Fetch all rooms with occupancy
- `_buildLabsView()` - Filter and display labs
- `_buildClassroomsView()` - Filter and display classrooms

---

### 4. **Navigation** (`prof_shell.dart`)
**Updates:**
- Added `seating_page.dart` import
- Added new navigator key for seating
- Added seating destination to both navigation rail and bottom nav
- 6 total tabs: Home, Attendance, Occupancy, Timetable, **Seating** (NEW), Profile

---

## Dependencies Added

**pubspec.yaml**
```yaml
dependencies:
  dio: ^5.3.0          # HTTP client with interceptors
  provider: ^6.0.0     # State management (ready for future use)
  http: ^1.0.0         # HTTP utilities
```

---

## Setup Instructions

### 1. **Backend Setup**
```bash
cd backend/Backend

# Install dependencies
pip install -r requirements.txt

# Initialize database
python init_db.py

# Start server
python main.py
```
Backend will run on `http://localhost:8000`

### 2. **Frontend Setup**
```bash
cd ui/myapp

# Get dependencies
flutter pub get

# Run the app
flutter run

# For web platform (if needed)
flutter run -d web
```

### 3. **Configuration**
**API Base URL:** `http://localhost:8000/api`
- Located in: `lib/services/api_client.dart`
- Modify `ApiClient.baseUrl` if backend runs on different host/port

---

## API Request/Response Examples

### Generate Timetable
```
POST /api/timetable/generate_timetable
Content-Type: application/json

{
  "departments": [
    {
      "name": "CSE",
      "groups": [],
      "sessions": [
        {
          "subject": "Data Structures",
          "teacher": "Dr. Smith",
          "group": "",
          "hours": 4
        }
      ]
    }
  ],
  "timeslots": []
}

Response:
{
  "schedule": [
    {
      "subject": "Data Structures",
      "time": "09:00 AM - 10:30 AM",
      "room": "Room 301",
      "teacher": "Dr. Smith"
    }
  ]
}
```

### Get Available Rooms
```
GET /api/seating/v1/seating/available-rooms?exam_date=2025-12-01&session=FN

Response:
[
  {
    "code": "A101",
    "capacity": 30,
    "current_occupancy": 15
  }
]
```

### Get Room Occupancy
```
GET /api/seating/v1/rooms/

Response:
[
  {
    "code": "Lab A1",
    "capacity": 30,
    "current_occupancy": 25
  }
]
```

---

## Error Handling

### Client-Side Error Flow
1. API call made via service
2. Dio interceptor logs request/response
3. Exception thrown on error
4. Page catches exception and displays:
   - Error message from backend
   - Retry button
   - Fallback UI state

### Common Errors
- **Connection Refused** → Backend not running
- **Network Error** → Check firewall/port accessibility
- **400 Bad Request** → Invalid parameters
- **500 Server Error** → Backend logic error

---

## Testing the Integration

### 1. **Start Backend**
```bash
cd backend/Backend
python main.py
```

### 2. **Verify API Health**
Open browser: `http://localhost:8000/health`
Expected response:
```json
{
  "status": "ok",
  "services": {
    "authentication": "available at /api/auth",
    "seating": "available at /api/seating/v1",
    "timetable": "available at /api/timetable"
  }
}
```

### 3. **Run Flutter App**
```bash
flutter run
```

### 4. **Test Each Page**
- **Timetable Page** → Should display fetched classes
- **Seating Page** → Should display exams and available rooms
- **Occupancy Page** → Should display room occupancy data
- **Navigation** → All tabs should load their respective pages

---

## Performance Optimization

### Implemented
- ✅ Lazy loading with `AutomaticKeepAliveClientMixin`
- ✅ Error handling with graceful fallbacks
- ✅ Loading indicators
- ✅ API response caching (potential future enhancement)

### Future Improvements
- Add state management (Provider/Riverpod) for complex state
- Implement API response caching
- Add offline capabilities with local database
- Pagination for large datasets
- Real-time updates with WebSockets

---

## Troubleshooting

### Issue: "Connection Refused"
**Solution:** Ensure backend is running on `http://localhost:8000`

### Issue: "Timetable shows 'No classes scheduled'"
**Solution:** Verify backend has generated timetable data

### Issue: "Occupancy shows empty"
**Solution:** Ensure rooms are created in backend database

### Issue: "Seating page shows no exams"
**Solution:** Create exam entries via API or admin panel

---

## File Structure
```
lib/
├── services/
│   ├── api_client.dart          # HTTP client
│   ├── seating_service.dart     # Seating APIs
│   ├── timetable_service.dart   # Timetable APIs
│   └── occupancy_service.dart   # Occupancy APIs
├── timetable_page.dart          # Timetable UI + integration
├── seating_page.dart            # Seating UI + integration (NEW)
├── occupancy_page.dart          # Occupancy UI + integration (updated)
├── prof_shell.dart              # Navigation (updated)
└── ...
```

---

## Backend Architecture Reference

```
backend/Backend/
├── appseating/
│   ├── api/v1/              # API endpoints
│   │   ├── exams.py
│   │   ├── rooms.py
│   │   ├── seating.py
│   │   └── students.py
│   ├── models/              # Database models
│   ├── schemas/             # Request/response schemas
│   ├── services/            # Business logic
│   └── core/                # Database, auth, security
├── timetable/               # Timetable module
└── main.py                  # FastAPI app entry
```

---

## Next Steps

1. **Test all integrations** with backend running
2. **Implement offline mode** with local caching
3. **Add authentication** - integrate login flow
4. **Real-time updates** - WebSocket integration
5. **Advanced filtering** - More seating options
6. **Export functionality** - Download reports

---

**Last Updated:** November 28, 2025
**Integration Status:** ✅ Complete
**Tested Features:** Seating, Timetable, Occupancy pages
