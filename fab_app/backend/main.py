from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from backend.api import worker_router, machine_router, assignment_router, search_router, dashboard_router, auth_router
from backend.infrastructure.database import get_db

app = FastAPI(title="Meerash Fab App API")

# Allow CORS for Vercel Frontend and Local Expo Dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://fabrication-app-chi.vercel.app",
        "https://fabrication-87g7exd2g-teamthunder.vercel.app",
        "http://localhost:8081",
        "http://localhost:19006",
        "http://192.168.137.1:8081",
        "http://localhost:5173", # Re-adding standard Vite local port just in case
        "http://localhost:3000"
    ],
    allow_origin_regex=r"https://fabrication-.*\.vercel\.app",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router.router)
app.include_router(worker_router.router)
app.include_router(machine_router.router)
app.include_router(assignment_router.router)
app.include_router(search_router.router)
app.include_router(dashboard_router.router)

@app.get("/")
def root():
    return {"message": "Welcome to Meerash API"}

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/seed")
def seed_database(db: Session = Depends(get_db)):
    from backend.domain.models import Floor, Mestri, Box
    
    # Check if we already have boxes
    existing = db.query(Box).first()
    if existing:
        return {"message": "Database already seeded."}
        
    # Create Floor 1
    floor = Floor(name="Floor 1")
    db.add(floor)
    db.commit()
    db.refresh(floor)
    
    # Create Mestri 1
    mestri = Mestri(name="Default Mestri", floor_id=floor.id)
    db.add(mestri)
    db.commit()
    db.refresh(mestri)
    
    # Create Boxes 1-10
    for i in range(1, 11):
        box = Box(id=i, name=f"Box {i}", mestri_id=mestri.id)
        db.add(box)
        
    db.commit()
    
    return {"message": "Seeded Floor 1, Default Mestri, and Boxes 1-10 successfully!"}

@app.get("/reset_all_data")
def reset_all_data(db: Session = Depends(get_db)):
    from backend.domain.models import Assignment, Worker, Machine, Box, Mestri, Floor
    
    # Delete in correct order to respect foreign keys
    db.query(Assignment).delete()
    db.query(Worker).delete()
    db.query(Machine).delete()
    db.query(Box).delete()
    db.query(Mestri).delete()
    db.query(Floor).delete()
    
    db.commit()
    return {"message": "Database wiped successfully! It is now completely fresh."}

