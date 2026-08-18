from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from backend.api.schemas import WorkerResponse, WorkerCreate, WorkerUpdate
from backend.infrastructure.database import get_db
from backend.application.worker_service import WorkerService
from backend.api.auth_router import get_current_admin
from backend.domain.models import Admin

router = APIRouter(prefix="/workers", tags=["workers"])

@router.get("/", response_model=List[WorkerResponse])
def get_all(db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = WorkerService(db)
    return svc.get_all()

@router.get("/{id}", response_model=WorkerResponse)
def get_one(id: int, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = WorkerService(db)
    worker = svc.get_one(id)
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")
    return worker

@router.post("/", response_model=WorkerResponse, status_code=201)
def create(data: WorkerCreate, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = WorkerService(db)
    return svc.create(data.model_dump(exclude_unset=True))

@router.put("/{id}", response_model=WorkerResponse)
def update(id: int, data: WorkerUpdate, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = WorkerService(db)
    return svc.update(id, data.model_dump(exclude_unset=True))

@router.delete("/{id}")
def delete(id: int, db: Session = Depends(get_db), admin: Admin = Depends(get_current_admin)):
    svc = WorkerService(db)
    svc.delete(id)
    return {"message": "Worker deactivated"}
