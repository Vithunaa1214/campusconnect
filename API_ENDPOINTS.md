# Complete API Endpoints Reference

## Integrated Backend - Exam Seating & Timetable Generation

**Server URL:** `http://localhost:8000`  
**Documentation:** `http://localhost:8000/docs`  
**Health Check:** `http://localhost:8000/health`

---

## 🏥 Common Endpoints

### `GET /`

API structure overview and service information.

### `GET /health`

Service health check.

```json
{
  "status": "ok",
  "services": {
    "seating": "available at /api/seating/v1",
    "timetable": "available at /api/timetable"
  }
}
```

---

## 📚 Exam Seating Service

**Base Path:** `/api/seating/v1`

### Rooms

| Method | Endpoint                           | Description                |
| ------ | ---------------------------------- | -------------------------- |
| POST   | `/api/seating/v1/rooms/bulk`       | Create multiple rooms      |
| GET    | `/api/seating/v1/rooms/`           | List all rooms             |
| POST   | `/api/seating/v1/rooms/upload-csv` | Bulk upload rooms from CSV |

### Students

| Method | Endpoint                              | Description                          |
| ------ | ------------------------------------- | ------------------------------------ |
| POST   | `/api/seating/v1/students/bulk`       | Create multiple students             |
| GET    | `/api/seating/v1/students/`           | List students (filter by dept/batch) |
| POST   | `/api/seating/v1/students/upload-csv` | Bulk upload students from CSV        |

**Query Parameters for GET:**

- `department_code` (optional): Filter by department
- `batch_year` (optional): Filter by batch year

### Exams

| Method | Endpoint                           | Description                |
| ------ | ---------------------------------- | -------------------------- |
| POST   | `/api/seating/v1/exams/`           | Create single exam         |
| GET    | `/api/seating/v1/exams/`           | List all exams             |
| POST   | `/api/seating/v1/exams/upload-csv` | Bulk upload exams from CSV |

### Seating Arrangements

| Method | Endpoint                                       | Description                    |
| ------ | ---------------------------------------------- | ------------------------------ |
| POST   | `/api/seating/v1/seating/generate`             | Generate seating for exam      |
| GET    | `/api/seating/v1/seating/available-rooms`      | Check room availability        |
| GET    | `/api/seating/v1/seating/by-room`              | Get seating for specific room  |
| GET    | `/api/seating/v1/seating/download-csv/by-room` | Download CSV for specific room |
| GET    | `/api/seating/v1/seating/download-csv/all`     | Download CSV for all rooms     |
| GET    | `/api/seating/v1/seating/svg/by-room`          | View SVG visualization         |

---

## 📅 Timetable Generation Service

**Base Path:** `/api/timetable`

### Timetable

| Method | Endpoint                            | Description                         |
| ------ | ----------------------------------- | ----------------------------------- |
| POST   | `/api/timetable/generate_timetable` | Generate timetables for departments |

---

## 📝 Request Examples

### 1. Upload Students CSV

```bash
curl -X POST "http://localhost:8000/api/seating/v1/students/upload-csv" \
  -F "file=@students.csv"
```

**CSV Format:**

```csv
register_no,name,department_code,department_name,batch_year
2023001,John Doe,CSE,Computer Science,2023
2024001,Jane Smith,ECE,Electronics,2024
```

### 2. Upload Rooms CSV

```bash
curl -X POST "http://localhost:8000/api/seating/v1/rooms/upload-csv" \
  -F "file=@rooms.csv"
```

**CSV Format:**

```csv
code,capacity,rows,columns
A101,30,5,6
B202,40,8,5
```

### 3. Create Exam

```bash
curl -X POST "http://localhost:8000/api/seating/v1/exams/" \
  -H "Content-Type: application/json" \
  -d '{
    "subject_code": "CS101",
    "subject_name": "Data Structures",
    "exam_date": "2025-12-01",
    "session": "FN",
    "department_batches": [
      {"department_code": "CSE", "batch_year": 2023},
      {"department_code": "IT", "batch_year": 2023}
    ]
  }'
```

### 4. Check Available Rooms

```bash
curl "http://localhost:8000/api/seating/v1/seating/available-rooms?exam_date=2025-12-01&session=FN"
```

### 5. Generate Seating

```bash
curl -X POST "http://localhost:8000/api/seating/v1/seating/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "exam_date": "2025-12-01",
    "session": "FN",
    "room_codes": ["A101", "B202"]
  }'
```

### 6. Download Seating CSV

```bash
curl "http://localhost:8000/api/seating/v1/seating/download-csv/all?exam_date=2025-12-01&session=FN" \
  -o seating.csv
```

### 7. Generate Timetable

```bash
curl -X POST "http://localhost:8000/api/timetable/generate_timetable" \
  -H "Content-Type: application/json" \
  -d '{
    "departments": [
      {
        "name": "CSE",
        "groups": [],
        "sessions": [
          {"subject": "Data Structures", "teacher": "Dr. Smith", "group": "", "hours": 4},
          {"subject": "Algorithms", "teacher": "Dr. Johnson", "group": "", "hours": 3}
        ]
      }
    ],
    "timeslots": []
  }'
```

---

## 🔗 Full Endpoint URLs

### Exam Seating Service

- `POST   http://localhost:8000/api/seating/v1/rooms/bulk`
- `GET    http://localhost:8000/api/seating/v1/rooms/`
- `POST   http://localhost:8000/api/seating/v1/rooms/upload-csv`
- `POST   http://localhost:8000/api/seating/v1/students/bulk`
- `GET    http://localhost:8000/api/seating/v1/students/`
- `POST   http://localhost:8000/api/seating/v1/students/upload-csv`
- `POST   http://localhost:8000/api/seating/v1/exams/`
- `GET    http://localhost:8000/api/seating/v1/exams/`
- `POST   http://localhost:8000/api/seating/v1/exams/upload-csv`
- `POST   http://localhost:8000/api/seating/v1/seating/generate`
- `GET    http://localhost:8000/api/seating/v1/seating/available-rooms`
- `GET    http://localhost:8000/api/seating/v1/seating/by-room`
- `GET    http://localhost:8000/api/seating/v1/seating/download-csv/by-room`
- `GET    http://localhost:8000/api/seating/v1/seating/download-csv/all`
- `GET    http://localhost:8000/api/seating/v1/seating/svg/by-room`

### Timetable Generation Service

- `POST   http://localhost:8000/api/timetable/generate_timetable`

---

## 📊 Quick Start Workflow

1. **Upload Data:**

   ```bash
   # Upload students
   curl -X POST http://localhost:8000/api/seating/v1/students/upload-csv -F "file=@students.csv"

   # Upload rooms
   curl -X POST http://localhost:8000/api/seating/v1/rooms/upload-csv -F "file=@rooms.csv"

   # Upload exams
   curl -X POST http://localhost:8000/api/seating/v1/exams/upload-csv -F "file=@exams.csv"
   ```

2. **Generate Seating:**

   ```bash
   curl -X POST http://localhost:8000/api/seating/v1/seating/generate \
     -H "Content-Type: application/json" \
     -d '{"exam_date": "2025-12-01", "session": "FN", "room_codes": []}'
   ```

3. **Download Results:**

   ```bash
   curl "http://localhost:8000/api/seating/v1/seating/download-csv/all?exam_date=2025-12-01&session=FN" -o seating.csv
   ```

4. **Generate Timetable:**
   ```bash
   curl -X POST http://localhost:8000/api/timetable/generate_timetable \
     -H "Content-Type: application/json" \
     -d @timetable_request.json -o timetable.json
   ```

---

## 📖 Interactive Documentation

Visit `http://localhost:8000/docs` to:

- Browse all available endpoints
- Test APIs interactively
- View request/response schemas
- See detailed parameter descriptions

---

**Last Updated:** November 2025
