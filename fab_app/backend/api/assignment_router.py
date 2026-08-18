from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from backend.api.schemas import AssignmentResponse, AssignmentDetailResponse, AssignmentCreate
from backend.infrastructure.database import get_db
from backend.application.assignment_service import AssignmentService
from backend.api.auth_router import get_current_admin
from backend.domain.models import Admin

router = APIRouter(prefix="/assignments", tags=["assignments"])

@router.post("/assign", response_model=AssignmentResponse)
def create_assignment(data: AssignmentCreate, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = AssignmentService(db)
    return svc.assign_machine(data.worker_id, data.machine_id, data.location, admin_id=admin.id)

@router.post("/{id}/return", response_model=AssignmentResponse)
def return_assignment(id: int, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = AssignmentService(db)
    return svc.return_machine(id, admin_id=admin.id)

from pydantic import BaseModel
class LocationUpdate(BaseModel):
    location: str

@router.patch("/{id}/location", response_model=AssignmentResponse)
def update_location(id: int, data: LocationUpdate, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = AssignmentService(db)
    return svc.update_location(id, data.location)

@router.get("/current", response_model=List[AssignmentDetailResponse])
def get_current(db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = AssignmentService(db)
    return svc.get_current()

@router.get("/history", response_model=List[AssignmentDetailResponse])
def get_history(db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = AssignmentService(db)
    return svc.get_history()

@router.get("/")
def get_all():
    raise NotImplementedError

@router.get("/{id}")
def get_one(id: int):
    raise NotImplementedError

@router.put("/{id}")
def update(id: int):
    raise NotImplementedError

@router.delete("/{id}")
def delete(id: int):
    raise NotImplementedError
