"""
Service layer for machine business logic.
"""
from sqlalchemy.orm import Session
from backend.infrastructure.machine_repository import MachineRepository
from backend.domain.models import Machine, Assignment
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
        """
        Update machine status with business-rule enforcement.

        Rules:
        - Cannot manually set an Assigned machine to Available (use the return workflow).
        - Cannot assign an Under Repair machine directly (use the assign workflow).
        - Cannot set status to Assigned manually (assignment workflow only).
        """
        machine = self.get_one(id)

        # Check if there is an active assignment for this machine
        active_assignment = (
            self.db.query(Assignment)
            .filter(Assignment.machine_id == id, Assignment.returned_at == None)
            .first()
        )

        # Block transitions that bypass the proper return workflow
        if machine.status == "Assigned" and new_status == "Available":
            raise HTTPException(
                status_code=400,
                detail=(
                    "Cannot manually set an Assigned machine to Available. "
                    "Use the Return Machine workflow to properly close the active assignment."
                )
            )

        # Block direct assignment via status endpoint (must go through assign workflow)
        if new_status == "Assigned":
            raise HTTPException(
                status_code=400,
                detail=(
                    "Cannot set machine status to 'Assigned' directly. "
                    "Use the Assign Machine workflow."
                )
            )

        # If machine has an active assignment, block any status change
        if active_assignment:
            raise HTTPException(
                status_code=400,
                detail=(
                    "Cannot change the status of a machine that has an active assignment. "
                    "Return the machine first."
                )
            )

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

        # Prevent deactivation if machine has an active assignment
        active_assignment = (
            self.db.query(Assignment)
            .filter(Assignment.machine_id == id, Assignment.returned_at == None)
            .first()
        )
        if active_assignment:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Cannot deactivate machine '{machine.name}' because it currently "
                    "has an active assignment. Return the machine first."
                )
            )

        return self.repo.delete(id)
