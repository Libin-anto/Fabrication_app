from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from backend.infrastructure.database import get_db
from backend.domain.models import Admin
from backend.api.schemas import AdminCreate, AdminLogin, AdminResponse, AdminProfileUpdate
from backend.infrastructure.security import hash_password, verify_password, create_access_token, verify_token

router = APIRouter(prefix="/auth", tags=["Auth"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_current_admin(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = verify_token(token)
    admin_id = payload.get("id")
    if admin_id is None:
        raise HTTPException(status_code=401, detail="Invalid token payload")
    admin = db.query(Admin).filter(Admin.id == admin_id).first()
    if admin is None:
        raise HTTPException(status_code=401, detail="Admin not found")
    return admin

@router.post("/register", response_model=AdminResponse, status_code=status.HTTP_201_CREATED)
def register(admin_in: AdminCreate, db: Session = Depends(get_db)):
    if not admin_in.username or not admin_in.username.strip():
        raise HTTPException(status_code=400, detail="Username cannot be empty")
        
    existing = db.query(Admin).filter(Admin.username == admin_in.username).first()
    if existing:
        raise HTTPException(status_code=400, detail="Username already registered")
        
    hashed = hash_password(admin_in.password)
    new_admin = Admin(username=admin_in.username, hashed_password=hashed)
    db.add(new_admin)
    db.commit()
    db.refresh(new_admin)
    return new_admin

@router.post("/login")
def login(admin_in: AdminLogin, db: Session = Depends(get_db)):
    admin = db.query(Admin).filter(Admin.username == admin_in.username).first()
    if not admin or not verify_password(admin_in.password, admin.hashed_password):
        # Generic error message to prevent username enumeration
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        
    access_token = create_access_token(data={"sub": admin.username, "id": admin.id})
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=AdminResponse)
def get_me(current_admin: Admin = Depends(get_current_admin)):
    return current_admin

@router.put("/me", response_model=AdminResponse)
def update_me(profile_in: AdminProfileUpdate, current_admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    if profile_in.name is not None:
        current_admin.name = profile_in.name
    if profile_in.role is not None:
        current_admin.role = profile_in.role
    db.commit()
    db.refresh(current_admin)
    return current_admin
