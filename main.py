# ============================================
# Python 3.13 Compatibility Patch
# ============================================
import sys
if sys.version_info >= (3, 13):
    # Monkey-patch ForwardRef for Python 3.13 compatibility with Pydantic
    import typing
    _original_evaluate = typing.ForwardRef._evaluate
    
    def _patched_evaluate(self, globalns, localns, *args, **kwargs):
        # Python 3.13 added 'recursive_guard' parameter
        if 'recursive_guard' not in kwargs:
            kwargs['recursive_guard'] = set()
        return _original_evaluate(self, globalns, localns, *args, **kwargs)
    
    typing.ForwardRef._evaluate = _patched_evaluate

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import seating app components
from appseating.core.db import Base, engine
from appseating.models import (
    department, batch, room, student, exam, 
    registration, seating, exam_department, exam_batch, user
)
from appseating.api.v1 import rooms, students, exams, seating as seating_api, auth

# Import timetable app
from timetable.app import app as timetable_app

# Create database tables for seating app (lazy initialization)
def init_db():
    """Initialize database tables - called on startup"""
    try:
        Base.metadata.create_all(bind=engine)
    except Exception as e:
        print(f"Warning: Database initialization skipped: {e}")
        print("Database connection will be attempted on first request")

# Main FastAPI application
app = FastAPI(
    title="Integrated Backend - Exam Seating & Timetable Generation",
    description="Combined API for exam seating arrangements, timetable generation, and user authentication",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production as needed
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================
# Lifespan Event - Initialize Database
# ============================================
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan context manager for startup and shutdown events"""
    # Startup event
    init_db()
    yield
    # Shutdown event (cleanup if needed)
    pass

app.router.lifespan_context = lifespan

# ============================================
# Authentication Routes (mounted at /api/auth)
# ============================================
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])

# ============================================
# Seating App Routes (mounted at /api/seating)
# ============================================
app.include_router(rooms.router, prefix="/api/seating/v1/rooms", tags=["Seating - Rooms"])
app.include_router(students.router, prefix="/api/seating/v1/students", tags=["Seating - Students"])
app.include_router(exams.router, prefix="/api/seating/v1/exams", tags=["Seating - Exams"])
app.include_router(seating_api.router, prefix="/api/seating/v1/seating", tags=["Seating - Arrangements"])

# ============================================
# Timetable App Routes (mounted at /api/timetable)
# ============================================
app.mount("/api/timetable", timetable_app)

# ============================================
# Health Check Endpoints
# ============================================
@app.get("/health", tags=["Health"])
def health_check():
    return {
        "status": "ok",
        "services": {
            "authentication": "available at /api/auth",
            "seating": "available at /api/seating/v1",
            "timetable": "available at /api/timetable"
        }
    }

@app.get("/", tags=["Root"])
def root():
    return {
        "message": "Integrated Backend API",
        "services": {
            "authentication": {
                "base_path": "/api/auth",
                "endpoints": [
                    "/api/auth/register",
                    "/api/auth/login",
                    "/api/auth/refresh",
                    "/api/auth/me",
                    "/api/auth/validate-email"
                ]
            },
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
                "endpoints": [
                    "/api/timetable/generate_timetable"
                ]
            }
        },
        "docs": "/docs",
        "health": "/health"
    }
