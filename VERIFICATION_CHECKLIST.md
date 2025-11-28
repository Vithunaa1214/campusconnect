# Integration Verification Checklist

## Pre-Integration Verification

- [ ] Python 3.13+ installed
- [ ] Flutter 3.9+ installed
- [ ] Git installed
- [ ] Backend code available at `backend/Backend/`
- [ ] Frontend code available at `ui/myapp/`

---

## Backend Setup

### Database & Server
- [ ] Navigate to `backend/Backend/`
- [ ] Run `pip install -r requirements.txt`
- [ ] Run `python init_db.py`
- [ ] Run `python main.py`
- [ ] Verify server starts without errors
- [ ] Server should output "Uvicorn running on http://127.0.0.1:8000"

### Backend Verification
- [ ] Open `http://localhost:8000/health` in browser
- [ ] Should return `{"status": "ok", "services": {...}}`
- [ ] Open `http://localhost:8000/docs` for API documentation
- [ ] All endpoints visible in Swagger UI

---

## Frontend Setup

### Dependencies
- [ ] Navigate to `ui/myapp/`
- [ ] Run `flutter pub get`
- [ ] No dependency conflicts
- [ ] All packages installed successfully

### Verify New Files
- [ ] `lib/services/api_client.dart` exists
- [ ] `lib/services/seating_service.dart` exists
- [ ] `lib/services/timetable_service.dart` exists
- [ ] `lib/services/occupancy_service.dart` exists
- [ ] `lib/seating_page.dart` exists
- [ ] `pubspec.yaml` has `dio` dependency
- [ ] `pubspec.yaml` has `provider` dependency

### Verify Updated Files
- [ ] `lib/timetable_page.dart` imports services
- [ ] `lib/occupancy_page.dart` imports services
- [ ] `lib/prof_shell.dart` imports `seating_page.dart`
- [ ] `lib/prof_shell.dart` has 6 navigation items

---

## Frontend Run

- [ ] Run `flutter run` or `flutter run -d web`
- [ ] App starts without errors
- [ ] No dependency issues
- [ ] App displays welcome screen or prof shell

---

## Navigation Verification

### Tab Navigation Check
- [ ] Can navigate to Home tab
- [ ] Can navigate to Attendance tab
- [ ] Can navigate to Occupancy tab
- [ ] Can navigate to Timetable tab
- [ ] Can navigate to **Seating tab** (NEW) ⭐
- [ ] Can navigate to Profile tab
- [ ] States persist when switching tabs
- [ ] Back button works correctly

---

## Timetable Page Integration

### UI Check
- [ ] Page loads without crashes
- [ ] Shows "Loading..." initially
- [ ] Day selector visible (Mon-Fri)
- [ ] Refresh button visible and clickable

### API Integration Check
- [ ] Timetable data fetches from backend
- [ ] Classes display with subject, time, room
- [ ] No hardcoded sample data (uses API data)
- [ ] Refresh button re-fetches data
- [ ] Loading spinner shows during fetch

### Error Handling Check
- [ ] If backend offline, shows error state
- [ ] Error message displays
- [ ] Retry button visible and functional
- [ ] Graceful handling of empty data

---

## Seating Page Integration (NEW)

### UI Check
- [ ] Page loads without crashes
- [ ] Exam dropdown visible
- [ ] Session selector (FN/AN) visible
- [ ] "Fetch Available Rooms" button visible
- [ ] "Generate Seating" button (FAB) visible

### API Integration Check
- [ ] Exams load from `/api/seating/v1/exams/`
- [ ] Available rooms fetch from `/api/seating/v1/seating/available-rooms`
- [ ] Seating generation calls `/api/seating/v1/seating/generate`
- [ ] Room data displays correctly

### Data Display Check
- [ ] Room codes display
- [ ] Room capacity displays
- [ ] Occupancy percentage shows
- [ ] Progress bars show occupancy
- [ ] Color coding works:
  - [ ] Green for low occupancy
  - [ ] Orange for medium
  - [ ] Red for critical

### Error Handling Check
- [ ] Error state displays if no exams
- [ ] Retry button works
- [ ] Appropriate error messages shown

---

## Occupancy Page Integration

### UI Check
- [ ] Page loads without crashes
- [ ] Two tabs visible: Labs & Classrooms
- [ ] Can switch between tabs
- [ ] Refresh button visible

### API Integration Check
- [ ] Room data fetches from `/api/seating/v1/rooms/`
- [ ] Uses real backend data (not hardcoded)
- [ ] Labs filtered correctly
- [ ] Classrooms filtered correctly

### Data Display Check
- [ ] Room names display
- [ ] Capacity displays
- [ ] Current occupancy displays
- [ ] Percentage calculates correctly
- [ ] Progress bars show occupancy
- [ ] Color indicators:
  - [ ] Green for low
  - [ ] Amber/Orange for medium
  - [ ] Red for critical
  - [ ] Grey for unknown

### Error Handling Check
- [ ] Empty state handles gracefully
- [ ] Error messages display
- [ ] Retry button functional

---

## API Connectivity Check

### Test Each Endpoint

**Timetable Endpoint**
- [ ] GET `http://localhost:8000/docs` works
- [ ] POST `/api/timetable/generate_timetable` callable
- [ ] Returns proper response structure

**Seating Endpoints**
- [ ] GET `/api/seating/v1/exams/` returns list
- [ ] GET `/api/seating/v1/seating/available-rooms` returns rooms
- [ ] POST `/api/seating/v1/seating/generate` creates arrangement
- [ ] GET `/api/seating/v1/seating/by-room` returns seating

**Occupancy Endpoint**
- [ ] GET `/api/seating/v1/rooms/` returns rooms list
- [ ] All rooms have occupancy data

---

## Error Handling Verification

### Connection Errors
- [ ] Stop backend
- [ ] Try to fetch timetable → shows error
- [ ] Try to fetch seating → shows error
- [ ] Try to fetch occupancy → shows error
- [ ] Retry button works when backend back online

### Invalid Data
- [ ] Empty responses handled gracefully
- [ ] Null values don't cause crashes
- [ ] Type mismatches handled

### Network Issues
- [ ] Timeout handled
- [ ] Connection refused handled
- [ ] Network unavailable handled

---

## Performance Check

- [ ] Pages load within 2 seconds
- [ ] No lag during scrolling
- [ ] Refresh doesn't freeze UI
- [ ] Error recovery is quick
- [ ] Memory usage reasonable
- [ ] No console errors/warnings

---

## Cross-Platform Check (If Testing on Multiple Platforms)

### Mobile (Android)
- [ ] App runs on physical device
- [ ] Backend URL accessible
- [ ] All features work

### Mobile (iOS)
- [ ] App runs on physical device
- [ ] Backend URL accessible
- [ ] All features work

### Web (if deploying)
- [ ] App runs in Chrome
- [ ] App runs in Firefox
- [ ] All features work

---

## Security Check

- [ ] No sensitive data logged
- [ ] Backend URL configurable
- [ ] Error messages don't expose internals
- [ ] No API keys in code
- [ ] HTTPS ready (for production)

---

## Documentation Check

- [ ] `INTEGRATION_GUIDE.md` exists and is readable
- [ ] `QUICK_START.md` exists and is accurate
- [ ] `INTEGRATION_SUMMARY.md` exists
- [ ] Backend API docs at `http://localhost:8000/docs`
- [ ] Backend endpoints documented in `API_ENDPOINTS.md`

---

## Final Testing Scenarios

### Scenario 1: Fresh Start
- [ ] Kill backend
- [ ] Kill frontend
- [ ] Start backend
- [ ] Start frontend
- [ ] All pages work correctly

### Scenario 2: Network Interruption
- [ ] Frontend running
- [ ] Kill backend mid-operation
- [ ] Frontend shows error
- [ ] Can retry when backend restarts

### Scenario 3: Data Updates
- [ ] Refresh timetable
- [ ] Refresh seating
- [ ] Refresh occupancy
- [ ] All show latest data

### Scenario 4: Tab Switching
- [ ] Open timetable
- [ ] Switch to seating
- [ ] Switch to occupancy
- [ ] Back to timetable
- [ ] Data persists, no refetch unless needed

---

## Sign-Off

| Component | Status | Issues | Notes |
|-----------|--------|--------|-------|
| Backend Setup | ☐ Pass ☐ Fail | | |
| Frontend Setup | ☐ Pass ☐ Fail | | |
| API Connectivity | ☐ Pass ☐ Fail | | |
| Timetable Integration | ☐ Pass ☐ Fail | | |
| Seating Integration | ☐ Pass ☐ Fail | | |
| Occupancy Integration | ☐ Pass ☐ Fail | | |
| Error Handling | ☐ Pass ☐ Fail | | |
| Navigation | ☐ Pass ☐ Fail | | |
| Performance | ☐ Pass ☐ Fail | | |
| Documentation | ☐ Pass ☐ Fail | | |

---

## Final Checklist

- [ ] Backend runs successfully
- [ ] Frontend connects to backend
- [ ] All three pages integrated and working
- [ ] Error handling verified
- [ ] Navigation updated
- [ ] Documentation complete
- [ ] No critical issues
- [ ] Ready for deployment

---

## Deployment Readiness

- [ ] Code reviewed
- [ ] All tests passed
- [ ] Documentation up to date
- [ ] Team trained
- [ ] Rollback plan ready
- [ ] Monitoring configured

---

**Integration Status:**
- If all boxes ✅: **READY TO DEPLOY**
- If any ❌: **IDENTIFY AND FIX BEFORE DEPLOYMENT**

**Date Completed:** ______________
**Verified By:** ______________
**Sign-Off:** ______________

---

**Good luck! 🚀**
