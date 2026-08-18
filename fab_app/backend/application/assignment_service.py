"""
Service layer for assignment business logic.
"""
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime
from backend.infrastructure.assignment_repository import AssignmentRepository
from backend.application.machine_service import MachineService
from backend.domain.models import Assignment, Machine
from fastapi import HTTPException


class AssignmentService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = AssignmentRepository(db)
        self.machine_service = MachineService(db)

    def assign_machine(self, worker_id: int, machine_id: int, location: str = "On Site", admin_id: int = None):
        """
        Atomically assign a machine to a worker.

        Uses SELECT FOR UPDATE to acquire a row-level lock on the machine record
        before checking availability. This prevents two concurrent requests from
        both reading 'Available' and creating duplicate active assignments.

        Only one concurrent request per machine can succeed; the second will
        receive a 409 Conflict error after the first transaction commits.
        """
        try:
            # ── Row-level lock on the machine record ──────────────────────────
            # This blocks any other transaction that also tries to lock the same
            # machine row until this transaction commits or rolls back.
            machine = (
                self.db.query(Machine)
                .filter(Machine.id == machine_id)
                .with_for_update()
                .first()
            )

            if not machine:
                raise HTTPException(status_code=404, detail="Machine not found")

            # ── Business rules ────────────────────────────────────────────────
            if machine.status != "Available":
                raise HTTPException(
                    status_code=409,
                    detail=f"Machine is currently '{machine.status}' and cannot be assigned."
                )

            # Verify worker is not already holding another machine
            active_assignment = self.repo.find_active_by_worker(worker_id)
            if active_assignment:
                raise HTTPException(
                    status_code=400,
                    detail="Worker is already assigned to a machine and must return it first."
                )

            # ── Create assignment and update machine atomically ───────────────
            assignment = Assignment(
                worker_id=worker_id,
                machine_id=machine_id,
                assigned_at=datetime.utcnow(),
                status="Assigned",
                location=location,
                assigned_by_admin_id=admin_id,
            )
            created = self.repo.create(assignment)
            machine.status = "Assigned"
            self.db.commit()
            self.db.refresh(created)
            return created

        except HTTPException:
            self.db.rollback()
            raise
        except Exception as e:
            self.db.rollback()
            raise HTTPException(status_code=500, detail="Transaction failed: " + str(e))

    def return_machine(self, assignment_id: int, admin_id: int = None):
        assignment = self.repo.find_by_id(assignment_id)
        if not assignment:
            raise HTTPException(status_code=404, detail="Assignment not found")
        if assignment.status == "Returned" or assignment.returned_at is not None:
            raise HTTPException(status_code=400, detail="Assignment is already returned.")

        machine = self.machine_service.get_one(assignment.machine_id)

        try:
            assignment.returned_at = datetime.utcnow()
            assignment.status = "Returned"
            assignment.returned_by_admin_id = admin_id
            machine.status = "Available"
            self.db.commit()
            self.db.refresh(assignment)
            return assignment
        except Exception as e:
            self.db.rollback()
            raise HTTPException(status_code=500, detail="Transaction failed: " + str(e))

    def update_location(self, assignment_id: int, location: str):
        if location not in ["On Site", "With Worker"]:
            raise HTTPException(status_code=400, detail="Location must be 'On Site' or 'With Worker'")

        assignment = self.repo.find_by_id(assignment_id)
        if not assignment:
            raise HTTPException(status_code=404, detail="Assignment not found")
        if assignment.status == "Returned" or assignment.returned_at is not None:
            raise HTTPException(status_code=400, detail="Cannot update location of returned assignment")

        try:
            assignment.location = location
            self.db.commit()
            self.db.refresh(assignment)
            return assignment
        except Exception as e:
            self.db.rollback()
            raise HTTPException(status_code=500, detail="Transaction failed: " + str(e))

    def get_current(self):
        results = self.repo.find_current()
        return self._format_detail_results(results)

    def get_history(self):
        results = self.repo.find_history()
        return self._format_detail_results(results)

    def _format_detail_results(self, results):
        formatted = []
        for row in results:
            assignment_obj = row[0]
            worker_name = row[1]
            machine_name = row[2]
            assigned_by_name_raw = row[3]
            assigned_by_username_raw = row[4]
            returned_by_name_raw = row[5]
            returned_by_username_raw = row[6]

            assigned_by = assigned_by_name_raw or assigned_by_username_raw
            returned_by = returned_by_name_raw or returned_by_username_raw

            data = {
                "id": assignment_obj.id,
                "worker_id": assignment_obj.worker_id,
                "machine_id": assignment_obj.machine_id,
                "assigned_at": assignment_obj.assigned_at,
                "returned_at": assignment_obj.returned_at,
                "status": assignment_obj.status,
                "location": assignment_obj.location,
                "worker_name": worker_name,
                "machine_name": machine_name,
                "assigned_by_name": assigned_by,
                "returned_by_name": returned_by,
            }
            formatted.append(data)
        return formatted
