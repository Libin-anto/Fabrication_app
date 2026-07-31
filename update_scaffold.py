import os

base_dir = r"c:\Users\Libin\PROJECT\Meerash\fab_app"

entities = ["worker", "machine", "assignment", "floor", "mestri", "box"]
routers = entities + ["auth"]
services = entities + ["auth"]
repos = entities

files = {}

# Routers
for r in routers:
    files[f"backend/api/{r}_router.py"] = f'''from fastapi import APIRouter

router = APIRouter(prefix="/{r}s", tags=["{r}s"])

@router.get("/")
def get_all():
    raise NotImplementedError

@router.get("/{{id}}")
def get_one(id: int):
    raise NotImplementedError

@router.post("/")
def create():
    raise NotImplementedError

@router.put("/{{id}}")
def update(id: int):
    raise NotImplementedError

@router.delete("/{{id}}")
def delete(id: int):
    raise NotImplementedError
'''

# Services
for s in services:
    files[f"backend/application/{s}_service.py"] = f'''"""
Service layer for {s} business logic.
"""

class {s.capitalize()}Service:
    def get_all(self):
        raise NotImplementedError
        
    def get_one(self, id: int):
        raise NotImplementedError
        
    def create(self, data):
        raise NotImplementedError
        
    def update(self, id: int, data):
        raise NotImplementedError
        
    def delete(self, id: int):
        raise NotImplementedError
'''

# Repositories
for rep in repos:
    files[f"backend/infrastructure/{rep}_repository.py"] = f'''"""
Database repository for {rep} entity.
"""

class {rep.capitalize()}Repository:
    def find_all(self):
        raise NotImplementedError
        
    def find_by_id(self, id: int):
        raise NotImplementedError
        
    def save(self, data):
        raise NotImplementedError
        
    def update(self, id: int, data):
        raise NotImplementedError
        
    def delete(self, id: int):
        raise NotImplementedError
'''

# Schemas
schemas_content = '''from pydantic import BaseModel
'''
for model in ["Admin", "Floor", "Mestri", "Box", "Worker", "Machine", "Assignment"]:
    schemas_content += f'''
class {model}Base(BaseModel):
    pass

class {model}Create({model}Base):
    pass

class {model}Update({model}Base):
    pass

class {model}Response({model}Base):
    pass
'''
files["backend/api/schemas.py"] = schemas_content

# Security
files["backend/infrastructure/security.py"] = '''"""
Security utility stubs for hashing and JWT.
"""

def hash_password(password: str) -> str:
    raise NotImplementedError

def verify_password(plain_password: str, hashed_password: str) -> bool:
    raise NotImplementedError

def create_access_token(data: dict) -> str:
    raise NotImplementedError

def verify_token(token: str) -> dict:
    raise NotImplementedError
'''

# Mobile App.tsx
files["mobile/App.tsx"] = '''import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

import Login from './src/screens/Login';
import Dashboard from './src/screens/Dashboard';
import WorkerList from './src/screens/WorkerList';
import WorkerForm from './src/screens/WorkerForm';
import MachineList from './src/screens/MachineList';
import MachineForm from './src/screens/MachineForm';
import AssignTool from './src/screens/AssignTool';
import CurrentAssignments from './src/screens/CurrentAssignments';
import AssignmentHistory from './src/screens/AssignmentHistory';

const Stack = createStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Login">
        <Stack.Screen name="Login" component={Login} />
        <Stack.Screen name="Dashboard" component={Dashboard} />
        <Stack.Screen name="WorkerList" component={WorkerList} />
        <Stack.Screen name="WorkerForm" component={WorkerForm} />
        <Stack.Screen name="MachineList" component={MachineList} />
        <Stack.Screen name="MachineForm" component={MachineForm} />
        <Stack.Screen name="AssignTool" component={AssignTool} />
        <Stack.Screen name="CurrentAssignments" component={CurrentAssignments} />
        <Stack.Screen name="AssignmentHistory" component={AssignmentHistory} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
'''

# write files
created_files = []
for file_path, content in files.items():
    full_path = os.path.join(base_dir, file_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content)
    created_files.append(full_path)

with open(os.path.join(base_dir, "created_files.txt"), 'w') as f:
    f.write("\\n".join(created_files))

print("Update complete.")
