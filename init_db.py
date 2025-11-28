#!/usr/bin/env python3
"""
Initialize the MySQL database for the seating application.
Run this script before starting the FastAPI app for the first time.
"""
import pymysql
import os
from dotenv import load_dotenv

load_dotenv()

MYSQL_USER = os.getenv("MYSQL_USER")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD")
MYSQL_HOST = os.getenv("MYSQL_HOST", "localhost")
MYSQL_PORT = int(os.getenv("MYSQL_PORT", "3306"))
MYSQL_DB = os.getenv("MYSQL_DB")

try:
    # Connect to MySQL server (without specifying database)
    connection = pymysql.connect(
        host=MYSQL_HOST,
        user=MYSQL_USER,
        password=MYSQL_PASSWORD,
        port=MYSQL_PORT
    )
    
    cursor = connection.cursor()
    
    # Create database if it doesn't exist
    cursor.execute(f"CREATE DATABASE IF NOT EXISTS {MYSQL_DB} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
    print(f"✓ Database '{MYSQL_DB}' created or already exists")
    
    # Verify database exists
    cursor.execute("SHOW DATABASES")
    databases = [db[0] for db in cursor.fetchall()]
    
    if MYSQL_DB in databases:
        print(f"✓ Confirmed: Database '{MYSQL_DB}' is available")
        print(f"\nConnection details:")
        print(f"  Host: {MYSQL_HOST}:{MYSQL_PORT}")
        print(f"  User: {MYSQL_USER}")
        print(f"  Database: {MYSQL_DB}")
        print(f"\nYou can now run: uvicorn app.main:app --reload")
    
    cursor.close()
    connection.close()
    
except pymysql.err.OperationalError as e:
    print(f"✗ Connection failed: {e}")
    print(f"\nTroubleshooting:")
    print(f"  1. Check if MySQL is running: systemctl status mysql")
    print(f"  2. Verify credentials in .env file")
    print(f"  3. Ensure user '{MYSQL_USER}' has necessary privileges")
except Exception as e:
    print(f"✗ Unexpected error: {e}")
