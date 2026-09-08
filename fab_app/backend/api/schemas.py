from pydantic import BaseModel, field_validator
from typing import Optional, Literal
from datetime import datetime

# ─── Auth ────────────────────────────────────────────────────────────────────

class AdminBase(BaseModel):
    username: str

class AdminCreate(AdminBase):
    password: str
    name: Optional[str] = None

class AdminLogin(AdminBase):
    password: str

class AdminProfileUpdate(BaseModel):
    name: Optional[str] = None
    role: Optional[str] = None

class AdminResponse(AdminBase):
    id: int
    name: Optional[str] = None
    role: Optional[str] = None
    class Config:
        from_attributes = True

# ─── Floors ──────────────────────────────────────────────────────────────────

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

# ─── Mestris ─────────────────────────────────────────────────────────────────

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

# ─── Boxes ───────────────────────────────────────────────────────────────────

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

# ─── Workers ─────────────────────────────────────────────────────────────────

class WorkerBase(BaseModel):
    name: str
    worker_id: str
    role: str  # Fabricator | Helper
    is_active: Optional[bool] = True
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

# ─── Machines ────────────────────────────────────────────────────────────────

# Strict enum for machine status — no arbitrary strings accepted
MachineStatusLiteral = Literal["Available", "Assigned", "Under Repair"]

class MachineBase(BaseModel):
    machine_id: str
    machine_number: str
    name: str
    category: Optional[str] = None
    status: MachineStatusLiteral
    remarks: Optional[str] = None
    is_active: bool

class MachineCreate(MachineBase):
    pass

class MachineUpdate(MachineBase):
    machine_id: Optional[str] = None
    machine_number: Optional[str] = None
    name: Optional[str] = None
    category: Optional[str] = None
    status: Optional[MachineStatusLiteral] = None
    remarks: Optional[str] = None
    is_active: Optional[bool] = None

class MachineStatusUpdate(BaseModel):
    status: MachineStatusLiteral  # Strict — only "Available", "Assigned", "Under Repair"

class MachineResponse(MachineBase):
    id: int
    class Config:
        from_attributes = True

# ─── Assignments ─────────────────────────────────────────────────────────────

class AssignmentBase(BaseModel):
    worker_id: int
    machine_id: int
    assigned_at: datetime
    status: str
    location: str = "On Site"

class AssignmentCreate(BaseModel):
    worker_id: int
    machine_id: int
    location: Optional[str] = "On Site"

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
    assigned_by_name: Optional[str] = None
    returned_by_name: Optional[str] = None
