from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from backend.api.schemas import MachineResponse, MachineStatusUpdate, MachineCreate, MachineUpdate
from backend.infrastructure.database import get_db
from backend.application.machine_service import MachineService
from backend.api.auth_router import get_current_admin
from backend.domain.models import Admin, Assignment

router = APIRouter(prefix="/machines", tags=["machines"])

@router.get("/", response_model=List[MachineResponse])
def get_all(status: Optional[str] = None, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = MachineService(db)
    return svc.get_all(status=status)

@router.get("/{id}", response_model=MachineResponse)
def get_one(id: int, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = MachineService(db)
    return svc.get_one(id)

@router.patch("/{id}/status", response_model=MachineResponse)
def update_status(id: int, update_data: MachineStatusUpdate, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = MachineService(db)
    return svc.set_status(id, update_data.status)

@router.post("/", response_model=MachineResponse, status_code=201)
def create(data: MachineCreate, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = MachineService(db)
    return svc.create(data.model_dump(exclude_unset=True))

@router.put("/{id}", response_model=MachineResponse)
def update(id: int, data: MachineUpdate, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = MachineService(db)
    return svc.update(id, data.model_dump(exclude_unset=True))

@router.delete("/{id}")
def delete(id: int, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = MachineService(db)
    svc.delete(id)
    return {"message": "Machine deactivated"}
