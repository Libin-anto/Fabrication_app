import os

base_dir = r"c:\Users\Libin\PROJECT\Meerash\fab_app"

files = {
    # Backend
    "backend/requirements.txt": "fastapi\nsqlalchemy\nalembic\npsycopg2-binary\npython-jose\npasslib\npydantic\nuvicorn\n",
    "backend/.env.example": "DATABASE_URL=postgresql://user:password@localhost/dbname\nSECRET_KEY=your-secret-key\n",
    "backend/alembic.ini": "[alembic]\nscript_location = alembic\n",
    "backend/alembic/versions/.keep": "",
    "backend/alembic/env.py": '"""Alembic env stub"""\npass\n',
    "backend/main.py": '"""Main FastAPI application entrypoint."""\nfrom fastapi import FastAPI\n\napp = FastAPI()\n',
    
    "backend/domain/__init__.py": '"""Domain layer: Contains business entities and interfaces."""\n',
    "backend/domain/models.py": '''"""
SQLAlchemy models for the domain.
"""
from sqlalchemy.orm import declarative_base
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime

Base = declarative_base()

class Admin(Base):
    __tablename__ = 'admins'
    id = Column(Integer, primary_key=True)
    # Auth fields go here

class Floor(Base):
    __tablename__ = 'floors'
    id = Column(Integer, primary_key=True)

class Mestri(Base):
    __tablename__ = 'mestris'
    id = Column(Integer, primary_key=True)
    floor_id = Column(Integer, ForeignKey('floors.id'))

class Box(Base):
    __tablename__ = 'boxes'
    id = Column(Integer, primary_key=True)
    mestri_id = Column(Integer, ForeignKey('mestris.id'))

class Worker(Base):
    __tablename__ = 'workers'
    id = Column(Integer, primary_key=True)
    box_id = Column(Integer, ForeignKey('boxes.id'))
    name = Column(String)
    worker_id = Column(String)
    role = Column(String) # Fabricator/Helper
    is_active = Column(Boolean, default=True)

class Machine(Base):
    __tablename__ = 'machines'
    id = Column(Integer, primary_key=True)
    machine_id = Column(String)
    machine_number = Column(String)
    name = Column(String)
    category = Column(String)
    status = Column(String) # Available/Assigned/Under Repair
    remarks = Column(String)
    is_active = Column(Boolean, default=True)

class Assignment(Base):
    __tablename__ = 'assignments'
    id = Column(Integer, primary_key=True)
    worker_id = Column(Integer, ForeignKey('workers.id'))
    machine_id = Column(Integer, ForeignKey('machines.id'))
    assigned_at = Column(DateTime)
    returned_at = Column(DateTime, nullable=True)
    status = Column(String)
''',
    "backend/application/__init__.py": '"""Application layer: Contains use cases, services, DTOs."""\n',
    "backend/infrastructure/__init__.py": '"""Infrastructure layer: Contains DB setup, external services, repositories."""\n',
    "backend/infrastructure/database.py": '"""Database session setup stub."""\n# sqlalchemy session maker goes here\npass\n',
    "backend/api/__init__.py": '"""API layer: Contains FastAPI routers and dependencies."""\n',
    
    # Mobile
    "mobile/package.json": '''{
  "name": "fab-app-mobile",
  "version": "1.0.0",
  "main": "node_modules/expo/AppEntry.js",
  "scripts": {
    "start": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios",
    "web": "expo start --web"
  },
  "dependencies": {
    "expo": "~49.0.8",
    "react": "18.2.0",
    "react-native": "0.72.4",
    "react-navigation": "^4.4.4",
    "axios": "^1.4.0",
    "zustand": "^4.4.1"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0",
    "typescript": "^5.1.3"
  },
  "private": true
}
''',
    "mobile/tsconfig.json": '''{
  "compilerOptions": {
    "strict": true,
    "jsx": "react-native"
  }
}
''',
    "mobile/app.json": '''{
  "expo": {
    "name": "fab-app-mobile",
    "slug": "fab-app-mobile",
    "version": "1.0.0"
  }
}
''',
    "mobile/src/services/api.ts": '// API Client Stub using axios\n// export const api = axios.create(...);\n',
    "mobile/src/store/index.ts": '// Zustand store stub for state management\n// export const useStore = create(...);\n',
    "mobile/src/components/index.ts": '// Export components here\n',
}

screens = [
    "Login", "Dashboard", "WorkerList", "WorkerForm", 
    "MachineList", "MachineForm", "AssignTool", 
    "CurrentAssignments", "AssignmentHistory"
]

for screen in screens:
    files[f"mobile/src/screens/{screen}.tsx"] = f'''import React from 'react';
import {{ View, Text }} from 'react-native';

export default function {screen}() {{
    return (
        <View>
            <Text>{screen} Screen Stub</Text>
        </View>
    );
}}
'''

for file_path, content in files.items():
    full_path = os.path.join(base_dir, file_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content)
print("Scaffolding complete.")
