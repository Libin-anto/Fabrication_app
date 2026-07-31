"""
SQLAlchemy models for the domain.
"""
from sqlalchemy.orm import declarative_base
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime

Base = declarative_base()

class Admin(Base):
    __tablename__ = 'admins'
    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True, nullable=False)
    hashed_password = Column(String, nullable=False)

class Floor(Base):
    __tablename__ = 'floors'
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)

class Mestri(Base):
    __tablename__ = 'mestris'
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    floor_id = Column(Integer, ForeignKey('floors.id'), nullable=False)

class Box(Base):
    __tablename__ = 'boxes'
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    mestri_id = Column(Integer, ForeignKey('mestris.id'), nullable=False)

class Worker(Base):
    __tablename__ = 'workers'
    id = Column(Integer, primary_key=True)
    box_id = Column(Integer, ForeignKey('boxes.id'), nullable=False)
    name = Column(String, nullable=False)
    worker_id = Column(String, unique=True, nullable=False)
    role = Column(String, nullable=False) # Fabricator/Helper
    is_active = Column(Boolean, default=True)

class Machine(Base):
    __tablename__ = 'machines'
    id = Column(Integer, primary_key=True)
    machine_id = Column(String, unique=True, nullable=False)
    machine_number = Column(String, nullable=False)
    name = Column(String, nullable=False)
    category = Column(String)
    status = Column(String, nullable=False) # Available/Assigned/Under Repair
    remarks = Column(String)
    is_active = Column(Boolean, default=True)

class Assignment(Base):
    __tablename__ = 'assignments'
    id = Column(Integer, primary_key=True)
    worker_id = Column(Integer, ForeignKey('workers.id'), nullable=False)
    machine_id = Column(Integer, ForeignKey('machines.id'), nullable=False)
    assigned_at = Column(DateTime, nullable=False)
    returned_at = Column(DateTime, nullable=True)
    status = Column(String, nullable=False)
    location = Column(String, nullable=False, default="On Site")
