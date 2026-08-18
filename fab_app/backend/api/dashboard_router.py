from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from backend.infrastructure.database import get_db
from backend.domain.models import Worker, Machine, Admin
from backend.api.auth_router import get_current_admin

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

@router.get("/stats")
def get_stats(db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    total_workers = db.query(func.count(Worker.id)).filter(Worker.is_active == True).scalar() or 0
    total_machines = db.query(func.count(Machine.id)).filter(Machine.is_active == True).scalar() or 0

    available = db.query(func.count(Machine.id)).filter(
        Machine.is_active == True,
        Machine.status == 'Available'
    ).scalar() or 0

    assigned = db.query(func.count(Machine.id)).filter(
        Machine.is_active == True,
        Machine.status == 'Assigned'
    ).scalar() or 0

    under_repair = db.query(func.count(Machine.id)).filter(
        Machine.is_active == True,
        Machine.status == 'Under Repair'
    ).scalar() or 0

    return {
        "total_workers": total_workers,
        "total_machines": total_machines,
        "available": available,
        "assigned": assigned,
        "under_repair": under_repair,
    }
