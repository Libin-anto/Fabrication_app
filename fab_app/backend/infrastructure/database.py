import sys
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    print(
        "\n[FATAL] DATABASE_URL environment variable is not set.\n"
        "The backend cannot start without a database connection.\n"
        "Set DATABASE_URL to your Supabase PostgreSQL connection string in Render.\n",
        file=sys.stderr,
    )
    sys.exit(1)

# Render/Supabase may use the legacy 'postgres://' scheme — normalize it
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# psycopg2 rejects the Supabase PgBouncer query-string parameter
if "?pgbouncer=true" in DATABASE_URL:
    DATABASE_URL = DATABASE_URL.replace("?pgbouncer=true", "")
    DATABASE_URL = DATABASE_URL.replace("&pgbouncer=true", "")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
