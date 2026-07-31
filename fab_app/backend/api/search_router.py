from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List
from backend.infrastructure.database import get_db
from backend.domain.models import Worker, Machine

router = APIRouter(prefix="/search", tags=["search"])

@router.get("/")
def search(q: str = "", db: Session = Depends(get_db)):
    if not q:
        return []
        
    term = f"%{q}%"
    
    # Search active workers
    workers = db.query(Worker).filter(
        Worker.is_active == True,
        or_(
            Worker.name.ilike(term),
            Worker.worker_id.ilike(term)
        )
    ).all()
    
    # Search active machines
    machines = db.query(Machine).filter(
        Machine.is_active == True,
        or_(
            Machine.name.ilike(term),
            Machine.machine_id.ilike(term)
        )
    ).all()
    
    results = []
    
    for w in workers:
        results.append({
            "type": "worker",
            "id": w.id,
            "display_id": w.worker_id,
            "name": w.name,
            "role": w.role
        })
        
    for m in machines:
        results.append({
            "type": "machine",
            "id": m.id,
            "display_id": m.machine_id,
            "name": m.name,
            "status": m.status,
            "category": m.category
        })
        
    return results
