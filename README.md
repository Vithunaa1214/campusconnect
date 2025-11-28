# Integrated Backend - Exam Seating & Timetable Generation

> **✨ NEW:** This application now combines two services into one integrated FastAPI backend!  
> **📚 Quick Reference:** See [API_ENDPOINTS.md](./API_ENDPOINTS.md) for complete endpoint documentation.

A comprehensive FastAPI backend service that combines two powerful applications:

1. **Exam Seating Management** - Automated seating arrangements for examinations
2. **Timetable Generation** - Intelligent timetable scheduling with constraint satisfaction

## 🚀 Quick Start

```bash
# Install dependencies
uv sync

# Configure .env file (see Setup section below)

# Initialize database
python init_db.py

# Run the integrated server
python -m uvicorn main:app --reload
```

**Access the application:**

- **API Documentation:** `http://localhost:8000/docs` (Interactive Swagger UI)
- **Health Check:** `http://localhost:8000/health`
- **API Overview:** `http://localhost:8000/`
- **Timetable Docs:** `http://localhost:8000/api/timetable/docs`

## 📌 Service Endpoints Summary

| Service      | Base URL          | Documentation                            |
| ------------ | ----------------- | ---------------------------------------- |
| Exam Seating | `/api/seating/v1` | Student, Room, Exam & Seating Management |
| Timetable    | `/api/timetable`  | CSP-based Timetable Generation           |

**👉 For complete API reference with examples, see [API_ENDPOINTS.md](./API_ENDPOINTS.md)**

## Features

### Exam Seating Management

- Student management with department and batch associations
- Exam scheduling with date and session (FN/AN) support
- Department-batch based exam allocation
- Room management with capacity tracking
- Room availability checking
- Automated seating arrangement generation with room selection
- CSV bulk upload for exams, students, and rooms
- SVG visualization of seating arrangements
- CSV export for printing hall tickets

### Timetable Generation

- Constraint Satisfaction Problem (CSP) based scheduling
- Multi-department timetable generation
- Teacher availability conflict detection
- Subject-teacher-group assignment
- Automatic break and lunch period handling
- 5-day, 10-period schedule support

## Tech Stack

- **Framework:** FastAPI
- **Database:** SQLAlchemy ORM (MySQL)
- **Python:** 3.13+
- **Dependencies:** See `pyproject.toml`
- **Package Manager:** uv

## Setup

1. Install dependencies:

```bash
uv sync
```

2. Configure environment variables:
   Create a `.env` file in the Backend directory:

```env
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DB=exam_seating
```

3. Initialize the database:

```bash
python init_db.py
```

4. Run the integrated server:

```bash
python -m uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

## API Documentation

Interactive API documentation is available at:

- **Swagger UI:** `http://localhost:8000/docs`
- **ReDoc:** `http://localhost:8000/redoc`
- **Root Endpoint:** `http://localhost:8000/` (API structure overview)
- **Health Check:** `http://localhost:8000/health`

---

## Complete API Endpoint Reference

### 🏥 Health & Information Endpoints

#### `GET /`

Get API structure overview and available services.

**Response:**

```json
{
  "message": "Integrated Backend API",
  "services": {
    "seating": {
      "base_path": "/api/seating/v1",
      "endpoints": [
        "/api/seating/v1/rooms",
        "/api/seating/v1/students",
        "/api/seating/v1/exams",
        "/api/seating/v1/seating"
      ]
    },
    "timetable": {
      "base_path": "/api/timetable",
      "endpoints": ["/api/timetable/generate_timetable"]
    }
  },
  "docs": "/docs",
  "health": "/health"
}
```

#### `GET /health`

Check service health status.

**Response:**

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

## 📚 Exam Seating Service API

Base Path: `/api/seating/v1`

### Rooms Endpoints

#### `POST /api/seating/v1/rooms/bulk`

Create multiple rooms at once.

**Request Body:**

```json
[
  {
    "code": "A101",
    "capacity": 30,
    "rows": 5,
    "columns": 6
  },
  {
    "code": "B202",
    "capacity": 40,
    "rows": 8,
    "columns": 5
  }
]
```

**Fields:**

- `code`: Room code (required)
- `capacity`: Room capacity (required)
- `rows`: Number of rows (optional, for SVG visualization)
- `columns`: Number of columns (optional, for SVG visualization)

#### `GET /api/seating/v1/rooms/`

List all rooms.

**Response:**

```json
[
  {
    "id": 1,
    "code": "A101",
    "capacity": 30,
    "rows": 5,
    "columns": 6
  }
]
```

#### `POST /api/seating/v1/rooms/upload-csv`

Upload a CSV file to bulk create rooms.

**Form Data:**

- `file`: CSV file

**CSV Format:**

```csv
code,capacity,rows,columns
A101,30,5,6
B202,40,8,5
C303,25,5,5
```

**Required Columns:**

- `code`: Room code/identifier
- `capacity`: Room capacity (integer)

**Optional Columns:**

- `rows`: Number of rows in the room (for SVG visualization)
- `columns`: Number of columns in the room (for SVG visualization)

---

### Students Endpoints

#### `POST /api/seating/v1/students/bulk`

Create multiple students at once.

**Request Body:**

```json
[
  {
    "register_no": "2021001",
    "name": "John Doe",
    "department_code": "CSE",
    "department_name": "Computer Science"
  }
]
```

#### `GET /api/seating/v1/students/`

List students with optional filtering by department and/or batch.

**Query Parameters:**

- `department_code`: Filter by department (optional)
- `batch_year`: Filter by batch year (optional)

**Filtering & Ordering Behavior:**

- **No filters**: Returns all students, ordered by department → batch → name
- **Department only**: Returns students from that department, ordered by batch → name
- **Batch only**: Returns students from that batch, ordered by department → name
- **Both**: Returns students from specific department-batch combination, ordered by name

**Examples:**

```bash
# All students (ordered by dept, batch, name)
GET /api/v1/students/

# CSE department students (ordered by batch, name)
GET /api/v1/students/?department_code=CSE

# 2023 batch students (ordered by department, name)
GET /api/seating/v1/students/?batch_year=2023

# CSE 2023 students (ordered by name)
GET /api/seating/v1/students/?department_code=CSE&batch_year=2023
```

**Response:**

```json
[
  {
    "id": 1,
    "register_no": "2021001",
    "name": "John Doe",
    "department_code": "CSE",
    "department_name": "Computer Science",
    "batch_year": 2023
  }
]
```

#### `POST /api/seating/v1/students/upload-csv`

Upload a CSV file to bulk create students.

**Form Data:**

- `file`: CSV file

**CSV Format:**

```csv
register_no,name,department_code,department_name,batch_year
2021001,John Doe,CSE,Computer Science,2023
2021002,Jane Smith,ECE,Electronics,2023
2021003,Bob Johnson,MECH,Mechanical,2024
2022001,Alice Williams,CSE,Computer Science,2024
```

**Required Columns:**

- `register_no`: Student register number
- `name`: Student name

**Optional Columns:**

- `department_code`: Department code
- `department_name`: Department full name
- `batch_year`: Batch year (e.g., 2023, 2024)

---

### Exams Endpoints

#### `POST /api/seating/v1/exams/`

Create a single exam.

**Request Body:**

```json
{
  "subject_code": "CS101",
  "subject_name": "Data Structures",
  "exam_date": "2025-12-01",
  "session": "FN",
  "department_batches": [
    { "department_code": "CSE", "batch_year": 2023 },
    { "department_code": "CSE", "batch_year": 2024 },
    { "department_code": "IT", "batch_year": 2023 }
  ]
}
```

**Fields:**

- `subject_code`: Subject/course code (required)
- `subject_name`: Subject/course name (required)
- `exam_date`: Exam date in YYYY-MM-DD format (required)
- `session`: Session - FN (Forenoon) or AN (Afternoon) (required)
- `department_batches`: List of department-batch combinations (required)
  - Each entry specifies which department and which batch should attend
  - Example: CSE 2023 batch, CSE 2024 batch, IT 2023 batch

**Session Values:**

- `FN`: Forenoon session
- `AN`: Afternoon session

**Important:** Only students from the specified department-batch combinations will be included in seating arrangements. This allows fine-grained control over which year groups attend each exam.

#### `GET /api/seating/v1/exams/`

List all exams.

**Response:**

```json
[
  {
    "id": 1,
    "subject_code": "CS101",
    "subject_name": "Data Structures",
    "exam_date": "2025-12-01",
    "session": "FN",
    "department_batches": [
      { "department_code": "CSE", "batch_year": 2023 },
      { "department_code": "CSE", "batch_year": 2024 },
      { "department_code": "IT", "batch_year": 2023 }
    ]
  }
]
```

#### `POST /api/seating/v1/exams/upload-csv`

Upload a CSV file to bulk create exams.

**Form Data:**

- `file`: CSV file

**CSV Format:**

```csv
subject_code,subject_name,exam_date,session,department_batches
CS101,Data Structures,2025-12-01,FN,"CSE:2023,CSE:2024,IT:2023"
CS102,Algorithms,2025-12-01,AN,"CSE:2023,IT:2024"
CS201,Operating Systems,2025-12-02,FN,"CSE:2024"
MA101,Mathematics,2025-12-03,FN,"CSE:2023,ECE:2023,MECH:2023"
```

**Required Columns:**

- `subject_code`: Subject/course code
- `subject_name`: Subject/course name
- `exam_date`: Exam date in YYYY-MM-DD format
- `session`: Session (FN or AN)

**Optional Columns:**

- `department_batches`: Comma-separated department:batch pairs (e.g., "CSE:2023,IT:2024,ECE:2023")
  - Format: `DEPT_CODE:BATCH_YEAR`
  - Example: `CSE:2023` means CSE department 2023 batch
  - Multiple combinations: `CSE:2023,CSE:2024,IT:2023`

---

### Seating Arrangements Endpoints

#### `POST /api/seating/v1/seating/generate`

Generate seating arrangements for a specific exam date and session.

**Request Body:**

```json
{
  "exam_date": "2025-12-01",
  "session": "FN",
  "room_codes": ["A101", "B202", "C303"]
}
```

**Fields:**

- `exam_date`: Date of exam (YYYY-MM-DD) - required
- `session`: Session (FN or AN) - required
- `room_codes`: List of room codes to use for seating - optional (if not provided, all rooms are used)

**Response:**

```json
{
  "status": "ok",
  "allocated": 45
}
```

**How it works:**

1. **No Registration Required**: All students from department-batch combinations are automatically included
2. **Department-Batch Filtering**: Only students matching BOTH department AND batch criteria are seated
   - Example: If exam specifies "CSE:2023", only CSE department students from 2023 batch attend
   - This allows separating different year groups (e.g., 2023 batch vs 2024 batch)
3. **Room Selection**: You can specify which rooms to use, or leave empty to use all available rooms
4. **Smart Distribution**: Students from the same department-batch are distributed across rooms to prevent clustering

**Important:**

- Exams MUST have department-batch combinations assigned before generating seating
- All students from assigned department-batch combinations will automatically attend
- No manual registration needed
- Batch separation ensures different year groups can have separate exams

#### `GET /api/seating/v1/seating/available-rooms`

Check room availability for a specific date and session.

**Query Parameters:**

- `exam_date`: Date (YYYY-MM-DD)
- `session`: Session (FN/AN)

**Example:**

```
GET /api/seating/v1/seating/available-rooms?exam_date=2025-12-01&session=FN
```

**Response:**

```json
{
  "exam_date": "2025-12-01",
  "session": "FN",
  "available_rooms": [
    {
      "code": "A101",
      "capacity": 30,
      "occupied_seats": 0,
      "available_seats": 30,
      "status": "available"
    },
    {
      "code": "B202",
      "capacity": 40,
      "occupied_seats": 25,
      "available_seats": 15,
      "status": "partial"
    },
    {
      "code": "C303",
      "capacity": 25,
      "occupied_seats": 25,
      "available_seats": 0,
      "status": "full"
    }
  ]
}
```

**Status Values:**

- `available`: Room has no seats occupied
- `partial`: Room has some seats occupied
- `full`: Room is at full capacity

#### `GET /api/seating/v1/seating/by-room`

Get seating arrangement for a specific room, date, and session.

**Query Parameters:**

- `exam_date`: Date (YYYY-MM-DD)
- `session`: Session (FN/AN)
- `room_code`: Room code

**Example:**

```
GET /api/seating/v1/seating/by-room?exam_date=2025-12-01&session=FN&room_code=A101
```

**Response:**

```json
{
  "room": "A101",
  "exam_date": "2025-12-01",
  "session": "FN",
  "seats": [
    {
      "seat_no": 1,
      "student_register_no": "2021001",
      "student_name": "John Doe",
      "department_code": "CSE",
      "subject_code": "CS101",
      "subject_name": "Data Structures"
    }
  ]
}
```

#### `GET /api/seating/v1/seating/download-csv/by-room`

Download seating arrangement for a specific room as CSV file.

**Query Parameters:**

- `exam_date`: Date (YYYY-MM-DD)
- `session`: Session (FN/AN)
- `room_code`: Room code

**Example:**

```
GET /api/seating/v1/seating/download-csv/by-room?exam_date=2025-12-01&session=FN&room_code=A101
```

**Response:**

- Content-Type: `text/csv`
- File download: `seating_A101_2025-12-01_FN.csv`

**CSV Format:**

```csv
Seat No,Register No,Student Name,Department,Subject Code,Subject Name,Room,Exam Date,Session
1,2021001,John Doe,CSE,CS101,Data Structures,A101,2025-12-01,FN
2,2021002,Jane Smith,ECE,CS101,Data Structures,A101,2025-12-01,FN
```

#### `GET /api/seating/v1/seating/download-csv/all`

Download seating arrangement for all rooms as a single CSV file.

**Query Parameters:**

- `exam_date`: Date (YYYY-MM-DD)
- `session`: Session (FN/AN)

**Example:**

```
GET /api/seating/v1/seating/download-csv/all?exam_date=2025-12-01&session=FN
```

**Response:**

- Content-Type: `text/csv`
- File download: `seating_all_rooms_2025-12-01_FN.csv`

**CSV Format:**

```csv
Room,Seat No,Register No,Student Name,Department,Subject Code,Subject Name,Exam Date,Session
A101,1,2021001,John Doe,CSE,CS101,Data Structures,2025-12-01,FN
A101,2,2021002,Jane Smith,ECE,CS101,Data Structures,2025-12-01,FN
B202,1,2021003,Bob Johnson,MECH,CS102,Algorithms,2025-12-01,FN
```

**Notes:**

- Results are sorted by room code and seat number
- Useful for printing hall tickets or seating charts
- Can be opened in Excel or Google Sheets

#### `GET /api/seating/v1/seating/svg/by-room`

Generate and display an SVG visualization of the seating arrangement for a specific room.

**Query Parameters:**

- `exam_date`: Date (YYYY-MM-DD)
- `session`: Session (FN/AN)
- `room_code`: Room code

**Example:**

```
GET /api/seating/v1/seating/svg/by-room?exam_date=2025-12-01&session=FN&room_code=A101
```

**Response:**

- Content-Type: `image/svg+xml`
- SVG image that can be displayed in browser or saved as file

**Features:**

- **Grid Layout**: If room has rows/columns defined, shows seats in a grid
- **List Layout**: If no grid dimensions, shows seats in a simple list
- **Visual Elements**:
  - Room title with capacity
  - Front/stage indicator
  - Seat numbers
  - Student register numbers and names
  - Occupied vs empty seats (different colors)
  - Row and column labels (A, B, C... and 1, 2, 3...)
  - Legend showing seat status

**Layout Types:**

1. **Grid Layout** (when room has rows and columns):

   - Shows exam hall as a grid with labeled rows and columns
   - Front/stage area at the top
   - Occupied seats in blue, empty seats in gray
   - Each seat shows: seat number, register number, student name

2. **List Layout** (when room has no rows/columns):
   - Shows seats in a vertical list
   - Each seat displays full student information
   - Useful for rooms without defined grid structure

**Usage:**

- Can be embedded in web pages: `<img src="http://localhost:8000/api/v1/seating/svg/by-room?exam_date=2025-12-01&session=FN&room_code=A101" />`
- Can be saved: Right-click → Save As in browser
- Can be printed directly from browser
- Can be converted to PDF using browser print functionality

---

## CSV Upload Examples

### Example: Uploading Exams CSV using curl

```bash
curl -X POST "http://localhost:8000/api/v1/exams/upload-csv" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@exams.csv"
```

### Example: Uploading Students CSV using Python

```python
import requests

with open('students.csv', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'http://localhost:8000/api/v1/students/upload-csv',
        files=files
    )
    print(response.json())
```

---

## CSV Download Examples

### Example: Downloading Seating CSV using curl

```bash
# Download seating for a specific room
curl -X GET "http://localhost:8000/api/v1/seating/download-csv/by-room?exam_date=2025-12-01&session=FN&room_code=A101" \
  -o seating_A101.csv

# Download seating for all rooms
curl -X GET "http://localhost:8000/api/v1/seating/download-csv/all?exam_date=2025-12-01&session=FN" \
  -o seating_all_rooms.csv
```

### Example: Downloading Seating CSV using Python

```python
import requests

# Download seating for a specific room
params = {
    'exam_date': '2025-12-01',
    'session': 'FN',
    'room_code': 'A101'
}
response = requests.get(
    'http://localhost:8000/api/v1/seating/download-csv/by-room',
    params=params
)

with open('seating_A101.csv', 'wb') as f:
    f.write(response.content)

# Download seating for all rooms
params = {
    'exam_date': '2025-12-01',
    'session': 'FN'
}
response = requests.get(
    'http://localhost:8000/api/v1/seating/download-csv/all',
    params=params
)

with open('seating_all_rooms.csv', 'wb') as f:
    f.write(response.content)
```

### Example: Download in Browser

Simply navigate to:

```
http://localhost:8000/api/v1/seating/download-csv/all?exam_date=2025-12-01&session=FN
```

The browser will automatically download the CSV file.

---

## Error Handling

All endpoints return appropriate HTTP status codes:

- `200 OK`: Successful request
- `400 Bad Request`: Invalid input data or missing required fields
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

Error responses include a detail message:

```json
{
  "detail": "Missing required column: exam_date"
}
```

---

## Database Models

### Student

- `id`: Primary key
- `register_no`: Unique student identifier
- `name`: Student name
- `department_id`: Foreign key to Department
- `batch_id`: Foreign key to Batch (year group)

### Exam

- `id`: Primary key
- `subject_code`: Subject code
- `subject_name`: Subject name
- `exam_date`: Date of exam
- `session`: FN (Forenoon) or AN (Afternoon)

### Batch

- `id`: Primary key
- `year`: Batch year (e.g., 2023, 2024)
- `name`: Batch name (e.g., "2023 Batch")

### ExamDepartmentBatch

- Links exams with specific department-batch combinations
- `exam_id`: Foreign key to Exam
- `department_code`: Department code
- `batch_year`: Batch year

### Room

- `id`: Primary key
- `code`: Unique room identifier
- `capacity`: Maximum number of students

### SeatingArrangement

- `exam_id`: Foreign key to Exam
- `student_id`: Foreign key to Student
- `room_id`: Foreign key to Room
- `seat_no`: Seat number assigned

---

## Development

### Project Structure

```
Backend/
├── main.py                          # ⭐ Integrated FastAPI application entry point
├── .env                              # Environment variables (database config)
├── init_db.py                        # Database initialization script
├── pyproject.toml                    # Project dependencies
├── uv.lock                           # Dependency lock file
├── README.md                         # This file
├── API_ENDPOINTS.md                  # Complete API endpoints reference
│
├── appseating/                       # 📚 Exam Seating Service
│   ├── __init__.py
│   ├── main.py                       # Original seating app (integrated into main.py)
│   ├── api/
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── exams.py              # Exam endpoints
│   │       ├── students.py           # Student endpoints
│   │       ├── rooms.py              # Room endpoints
│   │       ├── registrations.py      # Registration endpoints
│   │       └── seating.py            # Seating generation endpoints
│   ├── core/
│   │   └── db.py                     # Database configuration
│   ├── models/                       # SQLAlchemy database models
│   │   ├── __init__.py
│   │   ├── student.py
│   │   ├── exam.py
│   │   ├── room.py
│   │   ├── seating.py
│   │   ├── department.py
│   │   ├── batch.py
│   │   ├── exam_department.py
│   │   └── exam_batch.py
│   ├── schemas/                      # Pydantic validation schemas
│   │   ├── __init__.py
│   │   ├── student.py
│   │   ├── exam.py
│   │   ├── room.py
│   │   ├── seating.py
│   │   ├── registration.py
│   │   └── common.py
│   └── services/
│       ├── seating_service.py        # Seating allocation logic
│       └── svg_generator.py          # SVG visualization generation
│
└── timetable/                        # 📅 Timetable Generation Service
    ├── __init__.py
    └── app.py                        # Timetable FastAPI app with CSP logic
```

### Running Tests

```bash
# Add test commands here when tests are implemented
pytest
```

---

---

## 🎯 Complete Endpoint Summary

For detailed documentation of all endpoints with examples, see [API_ENDPOINTS.md](./API_ENDPOINTS.md)

### Exam Seating Service (`/api/seating/v1`)

| Category     | Method | Endpoint                                       | Description                   |
| ------------ | ------ | ---------------------------------------------- | ----------------------------- |
| **Rooms**    | POST   | `/api/seating/v1/rooms/bulk`                   | Create multiple rooms         |
|              | GET    | `/api/seating/v1/rooms/`                       | List all rooms                |
|              | POST   | `/api/seating/v1/rooms/upload-csv`             | Bulk upload from CSV          |
| **Students** | POST   | `/api/seating/v1/students/bulk`                | Create multiple students      |
|              | GET    | `/api/seating/v1/students/`                    | List students (filterable)    |
|              | POST   | `/api/seating/v1/students/upload-csv`          | Bulk upload from CSV          |
| **Exams**    | POST   | `/api/seating/v1/exams/`                       | Create exam                   |
|              | GET    | `/api/seating/v1/exams/`                       | List all exams                |
|              | POST   | `/api/seating/v1/exams/upload-csv`             | Bulk upload from CSV          |
| **Seating**  | POST   | `/api/seating/v1/seating/generate`             | Generate seating arrangements |
|              | GET    | `/api/seating/v1/seating/available-rooms`      | Check room availability       |
|              | GET    | `/api/seating/v1/seating/by-room`              | Get seating by room           |
|              | GET    | `/api/seating/v1/seating/download-csv/by-room` | Download room CSV             |
|              | GET    | `/api/seating/v1/seating/download-csv/all`     | Download all rooms CSV        |
|              | GET    | `/api/seating/v1/seating/svg/by-room`          | View SVG visualization        |

### Timetable Service (`/api/timetable`)

| Method | Endpoint                            | Description                   |
| ------ | ----------------------------------- | ----------------------------- |
| POST   | `/api/timetable/generate_timetable` | Generate CSP-based timetables |

### Common Endpoints

| Method | Endpoint  | Description                   |
| ------ | --------- | ----------------------------- |
| GET    | `/`       | API structure overview        |
| GET    | `/health` | Health check                  |
| GET    | `/docs`   | Interactive API documentation |

---

## License

[Add your license here]

## Contributing

[Add contributing guidelines here]
