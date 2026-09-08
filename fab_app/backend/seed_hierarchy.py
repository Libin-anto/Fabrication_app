from sqlalchemy.orm import Session
from backend.infrastructure.database import SessionLocal, engine
from backend.domain.models import Base, Floor, Mestri, Box

def seed_hierarchy():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        # Check if Floor exists
        floor = db.query(Floor).first()
        if not floor:
            floor = Floor(name="Main Floor")
            db.add(floor)
            db.commit()
            db.refresh(floor)
            print(f"Created Floor: {floor.name} (ID: {floor.id})")
        
        # Check if Mestri exists
        mestri = db.query(Mestri).first()
        if not mestri:
            mestri = Mestri(name="Default Mestri", floor_id=floor.id)
            db.add(mestri)
            db.commit()
            db.refresh(mestri)
            print(f"Created Mestri: {mestri.name} (ID: {mestri.id})")
            
        # Check if Box exists
        box = db.query(Box).first()
        if not box:
            box = Box(name="Box 1", mestri_id=mestri.id)
            db.add(box)
            db.commit()
            db.refresh(box)
            print(f"Created Box: {box.name} (ID: {box.id})")
            
        print("Hierarchy seed completed successfully.")
        
    except Exception as e:
        print(f"Error seeding hierarchy: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_hierarchy()
