"""
Service layer for machine business logic.
"""
from sqlalchemy.orm import Session
from backend.infrastructure.machine_repository import MachineRepository
from backend.domain.models import Machine
from fastapi import HTTPException

class MachineService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = MachineRepository(db)

    def get_all(self, status: str = None):
        return self.repo.find_all(status=status)
        
    def get_one(self, id: int):
        machine = self.repo.find_by_id(id)
        if not machine:
            raise HTTPException(status_code=404, detail="Machine not found")
        return machine

    def set_status(self, id: int, new_status: str):
        machine = self.get_one(id)
        return self.repo.update(id, {"status": new_status})
        
    def create(self, data: dict):
        if "name" in data:
            if not data.get("name") or not data.get("name").strip():
                raise HTTPException(status_code=400, detail="Name cannot be empty.")
                
        machine_id = data.get("machine_id")
        if "machine_id" in data:
            if not machine_id or not machine_id.strip():
                raise HTTPException(status_code=400, detail="Machine ID cannot be empty.")
        if machine_id is not None:
            existing = self.db.query(Machine).filter(Machine.machine_id == machine_id).first()
            if existing:
                raise HTTPException(status_code=400, detail=f"Machine ID {machine_id} is already in use.")
                
        return self.repo.save(data)
        
    def update(self, id: int, data: dict):
        machine = self.repo.find_by_id(id)
        if not machine:
            raise HTTPException(status_code=404, detail="Machine not found")
            
        if "name" in data:
            if not data.get("name") or not data.get("name").strip():
                raise HTTPException(status_code=400, detail="Name cannot be empty.")
                
        machine_id = data.get("machine_id")
        if "machine_id" in data:
            if not machine_id or not machine_id.strip():
                raise HTTPException(status_code=400, detail="Machine ID cannot be empty.")
        if machine_id is not None:
            existing = self.db.query(Machine).filter(Machine.machine_id == machine_id).first()
            if existing and existing.id != id:
                raise HTTPException(status_code=400, detail=f"Machine ID {machine_id} is already in use.")
                
        return self.repo.update(id, data)
        
    def delete(self, id: int):
        machine = self.repo.find_by_id(id)
        if not machine:
            raise HTTPException(status_code=404, detail="Machine not found")
        return self.repo.delete(id)
