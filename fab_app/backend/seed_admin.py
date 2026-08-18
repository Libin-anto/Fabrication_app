import os
from backend.infrastructure.database import SessionLocal
from backend.domain.models import Admin
from backend.infrastructure.security import hash_password

def seed_admin():
    """
    One-time admin seeding utility. Set SEED_ADMIN_USERNAME and SEED_ADMIN_PASSWORD
    as environment variables before running this script.

    This script will NOT overwrite an existing admin with the same username.
    Run once during initial setup only.

    Usage:
        SEED_ADMIN_USERNAME=myuser SEED_ADMIN_PASSWORD=mysecretpass python -m backend.seed_admin
    """
    db = SessionLocal()

    username = os.getenv("SEED_ADMIN_USERNAME")
    password = os.getenv("SEED_ADMIN_PASSWORD")

    if not username or not password:
        print(
            "[ERROR] SEED_ADMIN_USERNAME and SEED_ADMIN_PASSWORD must be set as "
            "environment variables. Refusing to seed without explicit credentials."
        )
        db.close()
        return

    existing = db.query(Admin).filter(Admin.username == username).first()
    if existing:
        print(f"Admin '{username}' already exists. No action taken.")
    else:
        hashed = hash_password(password)
        new_admin = Admin(username=username, hashed_password=hashed)
        db.add(new_admin)
        db.commit()
        print(f"Admin '{username}' seeded successfully.")

    db.close()

if __name__ == "__main__":
    seed_admin()
