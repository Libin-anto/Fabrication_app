import urllib.request
import urllib.error
import json
import base64
import sys
import os
sys.path.append(os.path.abspath('.'))

BASE_URL = "http://localhost:8000"

def make_request(method, endpoint, data=None, token=None):
    url = f"{BASE_URL}{endpoint}"
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
        
    if data:
        data = json.dumps(data).encode('utf-8')
        
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    
    try:
        with urllib.request.urlopen(req) as response:
            return response.status, json.loads(response.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        print(f"FAILED {method} {endpoint}: {e.code} - {e.read().decode('utf-8')}")
        sys.exit(1)

print("=== 1. Login as 4105/dhanush@123 ===")
status, response = make_request("POST", "/auth/login", {"username": "4105", "password": "dhanush@123"})
print(f"Status: {status}\nResponse: {json.dumps(response, indent=2)}\n")
token = response.get('access_token')

print("=== 2. Decode token payload ===")
payload_b64 = token.split('.')[1]
# Add padding if needed
payload_b64 += '=' * ((4 - len(payload_b64) % 4) % 4)
payload_json = base64.b64decode(payload_b64).decode('utf-8')
print(f"Payload: {json.dumps(json.loads(payload_json), indent=2)}\n")

print("=== 3. GET /auth/me ===")
status, response = make_request("GET", "/auth/me", token=token)
print(f"Status: {status}\nResponse: {json.dumps(response, indent=2)}\n")

print("=== 4. PUT /auth/me ===")
status, response = make_request("PUT", "/auth/me", {"name": "Test Name", "role": "Test Role"}, token=token)
print(f"Status: {status}\nResponse: {json.dumps(response, indent=2)}\n")

print("=== 5. GET /auth/me again ===")
status, response = make_request("GET", "/auth/me", token=token)
print(f"Status: {status}\nResponse: {json.dumps(response, indent=2)}\n")

print("=== 6. POST /assignments/assign ===")
# Fetch available worker and machine
_, workers = make_request("GET", "/workers/", token=token)
_, machines = make_request("GET", "/machines/?status=Available", token=token)

if not workers:
    print("Seeding a worker directly via DB since API endpoint might not exist...")
    from backend.infrastructure.database import SessionLocal
    from backend.domain.models import Floor, Mestri, Box, Worker, Machine
    db = SessionLocal()
    # Add minimal floor, mestri, box, worker, machine
    f = Floor(name="Test Floor")
    db.add(f)
    db.commit()
    m = Mestri(name="Test Mestri", floor_id=f.id)
    db.add(m)
    db.commit()
    b = Box(name="Test Box", mestri_id=m.id)
    db.add(b)
    db.commit()
    w = Worker(name="Test Worker", worker_id="W123", role="Fabricator", is_active=True, box_id=b.id)
    db.add(w)
    db.commit()
    worker_id = w.id
    db.close()
else:
    worker_id = workers[0]['id']

if not machines:
    print("Seeding a machine directly via DB...")
    db = SessionLocal()
    m2 = Machine(machine_id="M123", machine_number="MN123", name="Test Machine", status="Available", category="Heavy")
    db.add(m2)
    db.commit()
    machine_id = m2.id
    db.close()
else:
    machine_id = machines[0]['id']

status, assign_response = make_request("POST", "/assignments/assign", {
    "worker_id": worker_id,
    "machine_id": machine_id,
    "location": "On Site"
}, token=token)
print(f"Status: {status}\nResponse: {json.dumps(assign_response, indent=2)}\n")
assignment_id = assign_response['id']

print("=== 7. GET /assignments/current ===")
status, current = make_request("GET", "/assignments/current", token=token)
current_assignment = next((a for a in current if a['id'] == assignment_id), None)
print(f"Status: {status}")
print(f"Found current assignment: {json.dumps(current_assignment, indent=2)}\n")

print("=== 8. POST /assignments/{id}/return ===")
status, return_resp = make_request("POST", f"/assignments/{assignment_id}/return", token=token)
print(f"Status: {status}\nResponse: {json.dumps(return_resp, indent=2)}\n")

print("=== 9. GET /assignments/history ===")
status, history = make_request("GET", "/assignments/history", token=token)
history_assignment = next((a for a in history if a['id'] == assignment_id), None)
print(f"Status: {status}")
print(f"Found history assignment: {json.dumps(history_assignment, indent=2)}\n")

print("All tests passed!")
