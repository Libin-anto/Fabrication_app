"""
Service layer for worker business logic.
"""
from sqlalchemy.orm import Session
from fastapi import HTTPException
from backend.infrastructure.worker_repository import WorkerRepository
from backend.domain.models import Box, Worker, Assignment


class WorkerService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = WorkerRepository(db)

    def get_all(self):
        return self.repo.find_all(active_only=True)

    def get_one(self, id: int):
        return self.repo.find_by_id(id)

    def create(self, data: dict):
        if "name" in data:
            if not data.get("name") or not data.get("name").strip():
                raise HTTPException(status_code=400, detail="Name cannot be empty.")

        worker_id = data.get("worker_id")
        if "worker_id" in data:
            if not worker_id or not worker_id.strip():
                raise HTTPException(status_code=400, detail="Worker ID cannot be empty.")
        if worker_id is not None:
            existing = self.db.query(Worker).filter(Worker.worker_id == worker_id).first()
            if existing:
                raise HTTPException(status_code=400, detail=f"Worker ID {worker_id} is already in use.")

        box_id = data.get("box_id")
        if box_id:
            box = self.db.query(Box).filter(Box.id == box_id).first()
            if not box:
                raise HTTPException(status_code=400, detail=f"Box ID {box_id} does not exist.")

        return self.repo.save(data)

    def update(self, id: int, data: dict):
        worker = self.repo.find_by_id(id)
        if not worker:
            raise HTTPException(status_code=404, detail="Worker not found")

        if "name" in data:
            if not data.get("name") or not data.get("name").strip():
                raise HTTPException(status_code=400, detail="Name cannot be empty.")

        worker_id = data.get("worker_id")
        if "worker_id" in data:
            if not worker_id or not worker_id.strip():
                raise HTTPException(status_code=400, detail="Worker ID cannot be empty.")
        if worker_id is not None:
            existing = self.db.query(Worker).filter(Worker.worker_id == worker_id).first()
            if existing and existing.id != id:
                raise HTTPException(status_code=400, detail=f"Worker ID {worker_id} is already in use.")

        box_id = data.get("box_id")
        if box_id is not None:
            box = self.db.query(Box).filter(Box.id == box_id).first()
            if not box:
                raise HTTPException(status_code=400, detail=f"Box ID {box_id} does not exist.")

        return self.repo.update(id, data)

    def delete(self, id: int):
        worker = self.repo.find_by_id(id)
        if not worker:
            raise HTTPException(status_code=404, detail="Worker not found")

        # Prevent deactivation if worker has an active (unretured) assignment
        active_assignment = (
            self.db.query(Assignment)
            .filter(Assignment.worker_id == id, Assignment.returned_at == None)
            .first()
        )
        if active_assignment:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Cannot deactivate worker '{worker.name}' because they currently "
                    "have an active machine assignment. Return the machine first."
                )
            )

        return self.repo.delete(id)
