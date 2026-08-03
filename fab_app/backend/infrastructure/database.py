"""
Database session setup for Multi-Tenancy (PostgreSQL Schemas).
"""
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from fastapi import Request
import os

DATABASE_URL = os.getenv("DATABASE_URL")
if DATABASE_URL and DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# Global engine for Postgres
pg_engine = None
if DATABASE_URL and "postgresql" in DATABASE_URL:
    pg_engine = create_engine(DATABASE_URL)
    PgSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=pg_engine)

# Cache for SQLite engines
sqlite_engines = {}

def get_sqlite_engine(tenant_id: str):
    if tenant_id not in sqlite_engines:
        db_path = f"./tenant_{tenant_id}.db"
        url = f"sqlite:///{db_path}"
        engine = create_engine(url, connect_args={"check_same_thread": False})
        from backend.domain.models import Base
        Base.metadata.create_all(bind=engine)
        sqlite_engines[tenant_id] = engine
    return sqlite_engines[tenant_id]

# Track which Postgres schemas have been initialized to avoid running DDL on every request
initialized_pg_tenants = set()

def get_db(request: Request = None):
    # Try to get tenant ID from headers
    tenant_id = "public"
    if request and hasattr(request, "headers"):
        tenant_id = request.headers.get("X-Tenant-ID", "public")
        
    if pg_engine:
        db = PgSessionLocal()
        try:
            if tenant_id not in initialized_pg_tenants:
                # Create schema if it doesn't exist
                db.execute(text(f'CREATE SCHEMA IF NOT EXISTS "{tenant_id}"'))
                db.commit()
                
                # Set the search path to this tenant's schema
                db.execute(text(f'SET search_path TO "{tenant_id}"'))
                
                # Ensure tables exist in this schema using the current connection
                from backend.domain.models import Base
                Base.metadata.create_all(db.connection())
                
                initialized_pg_tenants.add(tenant_id)
            else:
                # Just set the search path for this request
                db.execute(text(f'SET search_path TO "{tenant_id}"'))
                
            yield db
        finally:
            db.close()
    else:
        # Fallback to SQLite Database-per-tenant
        engine = get_sqlite_engine(tenant_id)
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()
