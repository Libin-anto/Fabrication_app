import os
from backend.infrastructure.database import SessionLocal
from backend.domain.models import Admin
from backend.infrastructure.security import hash_password

def seed_admin():
    db = SessionLocal()
    
    username = "4105"
    password = "dhanush@123"
    
    existing = db.query(Admin).filter(Admin.username == username).first()
    if existing:
        print(f"Admin '{username}' already exists. No action taken.")
    else:
        hashed = hash_password(password)
        new_admin = Admin(username=username, hashed_password=hashed)
        db.add(new_admin)
        db.commit()
        print(f"Admin '{username}' seeded successfully!")
        
    db.close()

if __name__ == "__main__":
    seed_admin()
