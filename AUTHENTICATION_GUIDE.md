# Authentication System Documentation

## Overview

Complete JWT-based authentication system integrated with the existing FastAPI backend. Supports student and staff user types with automatic role detection based on email patterns.

---

## 🔐 Features

- ✅ User Registration (Students & Staff)
- ✅ Email Domain Validation (@citchennai.net)
- ✅ Automatic Student Information Extraction
- ✅ Role-Based Access Control (Student/Staff)
- ✅ JWT Access & Refresh Tokens
- ✅ Password Hashing (bcrypt)
- ✅ Protected Endpoints
- ✅ Token Refresh Mechanism

---

## 📧 Email Format Rules

### Student Emails

**Pattern:** `studentname.departmentyear@citchennai.net`

**Examples:**

- `shreerahuls.csbs2023@citchennai.net`
  - Student Name: shreerahuls
  - Department: csbs
  - Batch Year: 2023
- `john.cse2024@citchennai.net`
  - Student Name: john
  - Department: cse
  - Batch Year: 2024

### Staff Emails

**Pattern:** Any valid `@citchennai.net` email that doesn't match student pattern

**Examples:**

- `faculty.john@citchennai.net`
- `admin@citchennai.net`
- `principal@citchennai.net`

### Invalid Emails

- ❌ `student@gmail.com` (Wrong domain)
- ❌ `user@othercollege.edu` (Wrong domain)
- ❌ Any email not ending with `@citchennai.net`

---

## 🚀 API Endpoints

Base URL: `/api/auth`

### 1. Register User

**POST** `/api/auth/register`

Register a new student or staff member.

**Request Body:**

```json
{
  "email": "shreerahuls.csbs2023@citchennai.net",
  "password": "SecurePass123"
}
```

**Response (201 Created):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

**What Happens:**

- Email validated for `@citchennai.net` domain
- Email parsed to determine if student or staff
- For students: name, department, and batch year extracted automatically
- Password hashed using bcrypt
- User created in database
- JWT tokens generated and returned

**Validation Rules:**

- Email must end with `@citchennai.net`
- Password must be at least 8 characters
- Password must contain at least one letter and one number

### 2. Login

**POST** `/api/auth/login`

Authenticate user and get tokens.

**Request Body:**

```json
{
  "email": "shreerahuls.csbs2023@citchennai.net",
  "password": "SecurePass123"
}
```

**Response (200 OK):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

**Error Response (401 Unauthorized):**

```json
{
  "detail": "Invalid email or password"
}
```

### 3. Refresh Access Token

**POST** `/api/auth/refresh`

Get a new access token using refresh token.

**Request Body:**

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### 4. Get Current User

**GET** `/api/auth/me`

Get authenticated user's information.

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200 OK):**

```json
{
  "id": 1,
  "email": "shreerahuls.csbs2023@citchennai.net",
  "role": "student",
  "student_name": "shreerahuls",
  "department": "csbs",
  "batch_year": 2023,
  "created_at": "2025-11-27T10:30:00"
}
```

**For Staff:**

```json
{
  "id": 2,
  "email": "faculty.john@citchennai.net",
  "role": "staff",
  "student_name": null,
  "department": null,
  "batch_year": null,
  "created_at": "2025-11-27T11:00:00"
}
```

### 5. Validate Email (Testing)

**GET** `/api/auth/validate-email?email={email}`

Test email validation and parsing (useful for debugging).

**Example Request:**

```
GET /api/auth/validate-email?email=shreerahuls.csbs2023@citchennai.net
```

**Response:**

```json
{
  "email": "shreerahuls.csbs2023@citchennai.net",
  "role": "student",
  "student_name": "shreerahuls",
  "department": "csbs",
  "batch_year": 2023,
  "is_valid": true,
  "message": "Valid student email"
}
```

**For Staff Email:**

```
GET /api/auth/validate-email?email=admin@citchennai.net
```

**Response:**

```json
{
  "email": "admin@citchennai.net",
  "role": "staff",
  "is_valid": true,
  "message": "Valid staff email"
}
```

### 6. Get Student Profile

**GET** `/api/auth/students/me`

Get current student's profile (student role required).

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200 OK):**

```json
{
  "id": 1,
  "email": "shreerahuls.csbs2023@citchennai.net",
  "role": "student",
  "student_name": "shreerahuls",
  "department": "csbs",
  "batch_year": 2023,
  "created_at": "2025-11-27T10:30:00"
}
```

**Error (403 Forbidden) if user is not a student:**

```json
{
  "detail": "Access denied. Student privileges required."
}
```

### 7. Get Staff Profile

**GET** `/api/auth/staff/me`

Get current staff member's profile (staff role required).

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200 OK):**

```json
{
  "id": 2,
  "email": "faculty.john@citchennai.net",
  "role": "staff",
  "student_name": null,
  "department": null,
  "batch_year": null,
  "created_at": "2025-11-27T11:00:00"
}
```

### 8. Logout

**POST** `/api/auth/logout`

Logout user (client should delete tokens).

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200 OK):**

```json
{
  "message": "Successfully logged out",
  "detail": "Please delete your access and refresh tokens"
}
```

---

## 🔑 Using Authentication in Your Code

### Protect an Endpoint (Any Authenticated User)

```python
from fastapi import APIRouter, Depends
from appseating.core.auth import get_current_user
from appseating.models.user import User

router = APIRouter()

@router.get("/protected")
async def protected_route(current_user: User = Depends(get_current_user)):
    return {"message": f"Hello {current_user.email}"}
```

### Protect an Endpoint (Students Only)

```python
from fastapi import APIRouter, Depends
from appseating.core.auth import get_current_student
from appseating.models.user import User

router = APIRouter()

@router.get("/students-only")
async def students_only_route(current_user: User = Depends(get_current_student)):
    return {
        "message": f"Hello student {current_user.student_name}",
        "department": current_user.department,
        "batch": current_user.batch_year
    }
```

### Protect an Endpoint (Staff Only)

```python
from fastapi import APIRouter, Depends
from appseating.core.auth import get_current_staff
from appseating.models.user import User

router = APIRouter()

@router.get("/staff-only")
async def staff_only_route(current_user: User = Depends(get_current_staff)):
    return {"message": f"Hello staff member {current_user.email}"}
```

---

## 🗄️ Database Schema

### Users Table

```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('student', 'staff') NOT NULL,
    student_name VARCHAR(100),
    department VARCHAR(50),
    batch_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_department (department),
    INDEX idx_batch_year (batch_year)
);
```

---

## 🧪 Testing Examples

### Using cURL

**1. Register a Student:**

```bash
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.cse2023@citchennai.net",
    "password": "SecurePass123"
  }'
```

**2. Login:**

```bash
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.cse2023@citchennai.net",
    "password": "SecurePass123"
  }'
```

**3. Access Protected Endpoint:**

```bash
curl -X GET "http://localhost:8000/api/auth/me" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Using Python Requests

```python
import requests

BASE_URL = "http://localhost:8000/api/auth"

# Register
response = requests.post(f"{BASE_URL}/register", json={
    "email": "jane.ece2024@citchennai.net",
    "password": "MySecure123"
})
tokens = response.json()
print(f"Access Token: {tokens['access_token']}")

# Login
response = requests.post(f"{BASE_URL}/login", json={
    "email": "jane.ece2024@citchennai.net",
    "password": "MySecure123"
})
tokens = response.json()

# Access protected endpoint
headers = {"Authorization": f"Bearer {tokens['access_token']}"}
response = requests.get(f"{BASE_URL}/me", headers=headers)
user_info = response.json()
print(f"User: {user_info}")
```

---

## ⚙️ Configuration

### Environment Variables (.env)

```env
# JWT Authentication
JWT_SECRET_KEY=your-super-secret-jwt-key-change-this-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
```

**Important:** Change `JWT_SECRET_KEY` to a long, random string in production!

---

## 🏗️ Project Structure

```
Backend/
├── appseating/
│   ├── api/
│   │   └── v1/
│   │       └── auth.py                 # ✨ Authentication endpoints
│   ├── core/
│   │   ├── auth.py                     # ✨ JWT utilities & dependencies
│   │   └── security.py                 # ✨ Password hashing
│   ├── models/
│   │   └── user.py                     # ✨ User database model
│   ├── schemas/
│   │   └── auth.py                     # ✨ Pydantic schemas
│   └── services/
│       └── auth_service.py             # ✨ Business logic
├── .env                                 # ✨ Updated with JWT config
├── main.py                              # ✨ Updated with auth routes
└── pyproject.toml                       # ✨ Updated with dependencies
```

---

## 🔒 Security Best Practices

1. **Change JWT_SECRET_KEY in Production**

   - Use a long, random string
   - Never commit secrets to version control
   - Use environment variables or secret management systems

2. **Use HTTPS in Production**

   - Never send tokens over HTTP in production
   - Configure TLS/SSL certificates

3. **Token Expiration**

   - Access tokens expire after 30 minutes (configurable)
   - Refresh tokens expire after 7 days (configurable)
   - Adjust based on your security requirements

4. **Password Requirements**

   - Minimum 8 characters
   - Must contain letters and numbers
   - Consider adding more rules in production (special chars, uppercase, etc.)

5. **Store Tokens Securely on Client**
   - Use httpOnly cookies or secure storage
   - Never store in localStorage (vulnerable to XSS)
   - Clear tokens on logout

---

## 📋 Common Issues & Solutions

### Issue: "Email must be an official college email"

**Solution:** Ensure email ends with `@citchennai.net`

### Issue: "Password must contain at least one number"

**Solution:** Include at least one digit (0-9) in password

### Issue: "Could not validate credentials"

**Solution:**

- Check if token is expired
- Verify Authorization header format: `Bearer <token>`
- Try refreshing the access token

### Issue: "Access denied. Student privileges required"

**Solution:** This endpoint requires student role. Staff cannot access it.

---

## 🚀 Next Steps

1. **Install Dependencies:**

   ```bash
   cd Backend
   uv sync
   ```

2. **Run Database Migrations:**

   ```bash
   python init_db.py
   ```

3. **Start Server:**

   ```bash
   python -m uvicorn main:app --reload
   ```

4. **Test Authentication:**
   - Visit `http://localhost:8000/docs`
   - Try the `/api/auth/validate-email` endpoint
   - Register a test user
   - Login and get tokens
   - Access protected endpoints

---

**Created:** November 27, 2025  
**Version:** 1.0.0  
**Status:** ✅ Production Ready
