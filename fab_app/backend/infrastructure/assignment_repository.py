"""
Database repository for assignment entity.
"""
from sqlalchemy.orm import Session
from sqlalchemy import desc
from backend.domain.models import Assignment, Worker, Machine

class AssignmentRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, assignment: Assignment):
        self.db.add(assignment)
        # Note: flush instead of commit if we want to handle transactions in service
        self.db.flush()
        return assignment

    def find_current(self):
        return self.db.query(
            Assignment, Worker.name.label("worker_name"), Machine.name.label("machine_name")
        ).join(Worker, Assignment.worker_id == Worker.id)\
         .join(Machine, Assignment.machine_id == Machine.id)\
         .filter(Assignment.returned_at == None).all()
        
    def find_history(self):
        return self.db.query(
            Assignment, Worker.name.label("worker_name"), Machine.name.label("machine_name")
        ).join(Worker, Assignment.worker_id == Worker.id)\
         .join(Machine, Assignment.machine_id == Machine.id)\
         .order_by(desc(Assignment.assigned_at)).all()
        
    def find_by_id(self, id: int):
        return self.db.query(Assignment).filter(Assignment.id == id).first()
        
    def find_active_by_worker(self, worker_id: int):
        return self.db.query(Assignment).filter(
            Assignment.worker_id == worker_id,
            Assignment.returned_at == None
        ).first()
        
    def save(self, data):
        raise NotImplementedError
        
    def update(self, id: int, data):
        raise NotImplementedError
        
    def delete(self, id: int):
        raise NotImplementedError
