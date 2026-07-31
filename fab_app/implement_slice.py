import os

base_dir = r"c:\Users\Libin\PROJECT\Meerash\fab_app"

files = {}

# 1. database.py
files["backend/infrastructure/database.py"] = '''"""
Database session setup.
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

# Read from env in a real app, hardcode for scaffolding logic test
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./fab_app.db")

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
'''

# 2. schemas.py
files["backend/api/schemas.py"] = '''from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class AdminBase(BaseModel):
    username: str

class AdminCreate(AdminBase):
    password: str

class AdminUpdate(AdminBase):
    password: Optional[str] = None

class AdminResponse(AdminBase):
    id: int
    class Config:
        from_attributes = True

class FloorBase(BaseModel):
    name: str

class FloorCreate(FloorBase):
    pass

class FloorUpdate(FloorBase):
    pass

class FloorResponse(FloorBase):
    id: int
    class Config:
        from_attributes = True

class MestriBase(BaseModel):
    name: str
    floor_id: int

class MestriCreate(MestriBase):
    pass

class MestriUpdate(MestriBase):
    pass

class MestriResponse(MestriBase):
    id: int
    class Config:
        from_attributes = True

class BoxBase(BaseModel):
    name: str
    mestri_id: int

class BoxCreate(BoxBase):
    pass

class BoxUpdate(BoxBase):
    pass

class BoxResponse(BoxBase):
    id: int
    class Config:
        from_attributes = True

class WorkerBase(BaseModel):
    name: str
    worker_id: str
    role: str  # Fabricator | Helper
    is_active: bool
    box_id: int

class WorkerCreate(WorkerBase):
    pass

class WorkerUpdate(WorkerBase):
    name: Optional[str] = None
    worker_id: Optional[str] = None
    role: Optional[str] = None
    is_active: Optional[bool] = None
    box_id: Optional[int] = None

class WorkerResponse(WorkerBase):
    id: int
    class Config:
        from_attributes = True

class MachineBase(BaseModel):
    machine_id: str
    machine_number: str
    name: str
    category: str
    status: str  # Available | Assigned | Under Repair
    remarks: str
    is_active: bool

class MachineCreate(MachineBase):
    pass

class MachineUpdate(MachineBase):
    machine_id: Optional[str] = None
    machine_number: Optional[str] = None
    name: Optional[str] = None
    category: Optional[str] = None
    status: Optional[str] = None
    remarks: Optional[str] = None
    is_active: Optional[bool] = None

class MachineStatusUpdate(BaseModel):
    status: str

class MachineResponse(MachineBase):
    id: int
    class Config:
        from_attributes = True

class AssignmentBase(BaseModel):
    worker_id: int
    machine_id: int
    assigned_at: datetime
    status: str

class AssignmentCreate(BaseModel):
    worker_id: int
    machine_id: int

class AssignmentUpdate(AssignmentBase):
    returned_at: Optional[datetime] = None
    status: Optional[str] = None

class AssignmentResponse(AssignmentBase):
    id: int
    returned_at: Optional[datetime] = None
    class Config:
        from_attributes = True

class AssignmentDetailResponse(AssignmentResponse):
    worker_name: str
    machine_name: str
'''

# 3. worker_repository.py
files["backend/infrastructure/worker_repository.py"] = '''"""
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
        
    def save(self, data):
        raise NotImplementedError
        
    def update(self, id: int, data):
        raise NotImplementedError
        
    def delete(self, id: int):
        raise NotImplementedError
'''

# 4. machine_repository.py
files["backend/infrastructure/machine_repository.py"] = '''"""
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
        
    def save(self, data):
        raise NotImplementedError
        
    def update(self, id: int, data: dict):
        machine = self.find_by_id(id)
        if machine:
            for key, value in data.items():
                setattr(machine, key, value)
            self.db.commit()
            self.db.refresh(machine)
        return machine
        
    def delete(self, id: int):
        raise NotImplementedError
'''

# 5. assignment_repository.py
files["backend/infrastructure/assignment_repository.py"] = '''"""
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
        ).join(Worker, Assignment.worker_id == Worker.id)\\
         .join(Machine, Assignment.machine_id == Machine.id)\\
         .filter(Assignment.returned_at == None).all()
        
    def find_history(self):
        return self.db.query(
            Assignment, Worker.name.label("worker_name"), Machine.name.label("machine_name")
        ).join(Worker, Assignment.worker_id == Worker.id)\\
         .join(Machine, Assignment.machine_id == Machine.id)\\
         .order_by(desc(Assignment.assigned_at)).all()
        
    def find_by_id(self, id: int):
        return self.db.query(Assignment).filter(Assignment.id == id).first()
        
    def save(self, data):
        raise NotImplementedError
        
    def update(self, id: int, data):
        raise NotImplementedError
        
    def delete(self, id: int):
        raise NotImplementedError
'''

# 6. worker_service.py
files["backend/application/worker_service.py"] = '''"""
Service layer for worker business logic.
"""
from sqlalchemy.orm import Session
from backend.infrastructure.worker_repository import WorkerRepository

class WorkerService:
    def __init__(self, db: Session):
        self.repo = WorkerRepository(db)

    def get_all(self):
        return self.repo.find_all(active_only=True)
        
    def get_one(self, id: int):
        return self.repo.find_by_id(id)
        
    def create(self, data):
        raise NotImplementedError
        
    def update(self, id: int, data):
        raise NotImplementedError
        
    def delete(self, id: int):
        raise NotImplementedError
'''

# 7. machine_service.py
files["backend/application/machine_service.py"] = '''"""
Service layer for machine business logic.
"""
from sqlalchemy.orm import Session
from backend.infrastructure.machine_repository import MachineRepository
from fastapi import HTTPException

class MachineService:
    def __init__(self, db: Session):
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
        
    def create(self, data):
        raise NotImplementedError
        
    def update(self, id: int, data):
        raise NotImplementedError
        
    def delete(self, id: int):
        raise NotImplementedError
'''

# 8. assignment_service.py
files["backend/application/assignment_service.py"] = '''"""
Service layer for assignment business logic.
"""
from sqlalchemy.orm import Session
from datetime import datetime
from backend.infrastructure.assignment_repository import AssignmentRepository
from backend.application.machine_service import MachineService
from backend.domain.models import Assignment
from fastapi import HTTPException

class AssignmentService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = AssignmentRepository(db)
        self.machine_service = MachineService(db)

    def assign_machine(self, worker_id: int, machine_id: int):
        machine = self.machine_service.get_one(machine_id)
        if machine.status != "Available":
            raise HTTPException(status_code=400, detail=f"Machine is currently {machine.status} and cannot be assigned.")
        
        try:
            assignment = Assignment(
                worker_id=worker_id,
                machine_id=machine_id,
                assigned_at=datetime.utcnow(),
                status="Assigned"
            )
            created = self.repo.create(assignment)
            machine.status = "Assigned"
            self.db.commit()
            self.db.refresh(created)
            return created
        except Exception as e:
            self.db.rollback()
            raise HTTPException(status_code=500, detail="Transaction failed: " + str(e))

    def return_machine(self, assignment_id: int):
        assignment = self.repo.find_by_id(assignment_id)
        if not assignment:
            raise HTTPException(status_code=404, detail="Assignment not found")
        if assignment.status == "Returned" or assignment.returned_at is not None:
            raise HTTPException(status_code=400, detail="Assignment is already returned.")
            
        machine = self.machine_service.get_one(assignment.machine_id)
        
        try:
            assignment.returned_at = datetime.utcnow()
            assignment.status = "Returned"
            machine.status = "Available"
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
            assignment_obj, worker_name, machine_name = row
            # Create a dict to match AssignmentDetailResponse schema
            data = {
                "id": assignment_obj.id,
                "worker_id": assignment_obj.worker_id,
                "machine_id": assignment_obj.machine_id,
                "assigned_at": assignment_obj.assigned_at,
                "returned_at": assignment_obj.returned_at,
                "status": assignment_obj.status,
                "worker_name": worker_name,
                "machine_name": machine_name
            }
            formatted.append(data)
        return formatted
'''

# 9. worker_router.py
files["backend/api/worker_router.py"] = '''from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from backend.api.schemas import WorkerResponse
from backend.infrastructure.database import get_db
from backend.application.worker_service import WorkerService

router = APIRouter(prefix="/workers", tags=["workers"])

@router.get("/", response_model=List[WorkerResponse])
def get_all(db: Session = Depends(get_db)):
    svc = WorkerService(db)
    return svc.get_all()

@router.get("/{id}", response_model=WorkerResponse)
def get_one(id: int, db: Session = Depends(get_db)):
    svc = WorkerService(db)
    worker = svc.get_one(id)
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")
    return worker

@router.post("/")
def create():
    raise NotImplementedError

@router.put("/{id}")
def update(id: int):
    raise NotImplementedError

@router.delete("/{id}")
def delete(id: int):
    raise NotImplementedError
'''

# 10. machine_router.py
files["backend/api/machine_router.py"] = '''from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from backend.api.schemas import MachineResponse, MachineStatusUpdate
from backend.infrastructure.database import get_db
from backend.application.machine_service import MachineService

router = APIRouter(prefix="/machines", tags=["machines"])

@router.get("/", response_model=List[MachineResponse])
def get_all(status: Optional[str] = None, db: Session = Depends(get_db)):
    svc = MachineService(db)
    return svc.get_all(status=status)

@router.get("/{id}", response_model=MachineResponse)
def get_one(id: int, db: Session = Depends(get_db)):
    svc = MachineService(db)
    return svc.get_one(id)
    
@router.patch("/{id}/status", response_model=MachineResponse)
def update_status(id: int, update_data: MachineStatusUpdate, db: Session = Depends(get_db)):
    svc = MachineService(db)
    return svc.set_status(id, update_data.status)

@router.post("/")
def create():
    raise NotImplementedError

@router.put("/{id}")
def update(id: int):
    raise NotImplementedError

@router.delete("/{id}")
def delete(id: int):
    raise NotImplementedError
'''

# 11. assignment_router.py
files["backend/api/assignment_router.py"] = '''from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from backend.api.schemas import AssignmentResponse, AssignmentDetailResponse, AssignmentCreate
from backend.infrastructure.database import get_db
from backend.application.assignment_service import AssignmentService

router = APIRouter(prefix="/assignments", tags=["assignments"])

@router.post("/assign", response_model=AssignmentResponse)
def create_assignment(data: AssignmentCreate, db: Session = Depends(get_db)):
    svc = AssignmentService(db)
    return svc.assign_machine(data.worker_id, data.machine_id)

@router.post("/{id}/return", response_model=AssignmentResponse)
def return_assignment(id: int, db: Session = Depends(get_db)):
    svc = AssignmentService(db)
    return svc.return_machine(id)

@router.get("/current", response_model=List[AssignmentDetailResponse])
def get_current(db: Session = Depends(get_db)):
    svc = AssignmentService(db)
    return svc.get_current()

@router.get("/history", response_model=List[AssignmentDetailResponse])
def get_history(db: Session = Depends(get_db)):
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
'''

# Write all modified files
import os
for path, content in files.items():
    full_path = os.path.join(base_dir, path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content.strip() + '\n')
        
print("Updated all backend files.")
