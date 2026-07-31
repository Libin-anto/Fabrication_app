"""
Database repository for worker entity.
"""
from sqlalchemy.orm import Session
from backend.domain.models import Worker

class WorkerRepository:
    def __init__(self, db: Session):
        self.db = db

    def find_all(self, active_only: bool = True):
        query = self.db.query(Worker)
        if active_only:
            query = query.filter(Worker.is_active == True)
        return query.all()
        
    def find_by_id(self, id: int):
        return self.db.query(Worker).filter(Worker.id == id).first()
        
    def save(self, data: dict):
        worker = Worker(**data)
        self.db.add(worker)
        self.db.commit()
        self.db.refresh(worker)
        return worker
        
    def update(self, id: int, data: dict):
        worker = self.find_by_id(id)
        if worker:
            for key, value in data.items():
                setattr(worker, key, value)
            self.db.commit()
            self.db.refresh(worker)
        return worker
        
    def delete(self, id: int):
        worker = self.find_by_id(id)
        if worker:
            worker.is_active = False
            self.db.commit()
            self.db.refresh(worker)
        return worker
