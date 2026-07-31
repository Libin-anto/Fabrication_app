"""
Database repository for machine entity.
"""
from sqlalchemy.orm import Session
from backend.domain.models import Machine

class MachineRepository:
    def __init__(self, db: Session):
        self.db = db

    def find_all(self, status: str = None):
        query = self.db.query(Machine).filter(Machine.is_active == True)
        if status:
            query = query.filter(Machine.status == status)
        return query.all()
        
    def find_by_id(self, id: int):
        return self.db.query(Machine).filter(Machine.id == id).first()
        
    def save(self, data: dict):
        machine = Machine(**data)
        self.db.add(machine)
        self.db.commit()
        self.db.refresh(machine)
        return machine
        
    def update(self, id: int, data: dict):
        machine = self.find_by_id(id)
        if machine:
            for key, value in data.items():
                setattr(machine, key, value)
            self.db.commit()
            self.db.refresh(machine)
        return machine
        
    def delete(self, id: int):
        machine = self.find_by_id(id)
        if machine:
            machine.is_active = False
            self.db.commit()
            self.db.refresh(machine)
        return machine
