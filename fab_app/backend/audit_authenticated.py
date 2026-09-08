import urllib.request
import urllib.error
import json
import time

BASE_URL = "http://127.0.0.1:8000"
log_lines = []
token = None

def get_auth_token():
    url = f"{BASE_URL}/auth/login"
    req = urllib.request.Request(url, method="POST")
    req.add_header('Content-Type', 'application/json')
    data = json.dumps({"username": "4105", "password": "dhanush@123"}).encode('utf-8')
    try:
        with urllib.request.urlopen(req, data=data) as response:
            res = json.loads(response.read().decode('utf-8'))
            return res.get("access_token")
    except Exception as e:
        print(f"Login failed: {e}")
        return None

def log_req_res(method, url, json_data=None):
    log_lines.append("--------------------------------------------------")
    req_str = f"REQUEST: {method} {url}"
    if json_data is not None:
        req_str += f"\nBODY: {json.dumps(json_data)}"
    log_lines.append(req_str)
    
    req = urllib.request.Request(url, method=method)
    req.add_header('Content-Type', 'application/json')
    if token:
        req.add_header('Authorization', f'Bearer {token}')
    if json_data is not None:
        req.data = json.dumps(json_data).encode('utf-8')
        
    try:
        with urllib.request.urlopen(req) as response:
            status = response.getcode()
            body = response.read().decode('utf-8')
            res_str = f"RESPONSE: {status}\nBODY: {body}"
            log_lines.append(res_str)
            try:
                return status, json.loads(body) if body else None
            except:
                return status, None
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8')
        res_str = f"RESPONSE: {e.code}\nBODY: {body}"
        log_lines.append(res_str)
        try:
            return e.code, json.loads(body) if body else None
        except:
            return e.code, None
    except Exception as e:
        log_lines.append(f"EXCEPTION: {str(e)}")
        return None, None

token = get_auth_token()
if not token:
    print("Could not obtain auth token. Make sure local uvicorn is running on 8000 and admin exists.")
    exit(1)

ts = str(int(time.time()))

# 1. Workers
log_lines.append("=== WORKERS ===")
log_req_res("GET", f"{BASE_URL}/workers/")
status, w_res = log_req_res("POST", f"{BASE_URL}/workers/", {"name": "Test Worker", "worker_id": f"TW-{ts}", "role": "Fabricator", "box_id": 3, "is_active": True})
if status in (200, 201) and w_res:
    w_id = w_res.get("id")
    log_req_res("GET", f"{BASE_URL}/workers/{w_id}")
    log_req_res("POST", f"{BASE_URL}/workers/", {"name": "Duplicate Worker", "worker_id": f"TW-{ts}", "role": "Helper", "box_id": 3, "is_active": True})
    log_req_res("POST", f"{BASE_URL}/workers/", {"name": "", "worker_id": f"TW2-{ts}", "role": "Helper", "box_id": 3, "is_active": True})
    log_req_res("PUT", f"{BASE_URL}/workers/{w_id}", {"name": "Updated Worker", "worker_id": f"TW-{ts}", "role": "Fabricator", "box_id": 3, "is_active": True})
    # We will test soft-delete later after assignments testing to ensure we check deactivation protection

# 2. Machines
log_lines.append("\n=== MACHINES ===")
log_req_res("GET", f"{BASE_URL}/machines/")
status, m_res = log_req_res("POST", f"{BASE_URL}/machines/", {"name": "Test Machine", "machine_id": f"TM-{ts}", "machine_number": f"SN-{ts}", "category": "Drill", "status": "Available", "is_active": True})
if status in (200, 201) and m_res:
    m_id = m_res.get("id")
    log_req_res("GET", f"{BASE_URL}/machines/{m_id}")
    log_req_res("POST", f"{BASE_URL}/machines/", {"name": "Dup Machine", "machine_id": f"TM-{ts}", "machine_number": f"SN-{ts}2", "category": "Drill", "status": "Available", "is_active": True})
    log_req_res("POST", f"{BASE_URL}/machines/", {"name": "", "machine_id": f"TM2-{ts}", "machine_number": f"SN-{ts}3", "category": "Drill", "status": "Available", "is_active": True})
    log_req_res("PUT", f"{BASE_URL}/machines/{m_id}", {"name": "Updated Machine", "machine_id": f"TM-{ts}", "machine_number": f"SN-{ts}", "category": "Saw", "status": "Available", "is_active": True})

# 3. Assignments
log_lines.append("\n=== ASSIGNMENTS ===")
_, w_assign_res = log_req_res("POST", f"{BASE_URL}/workers/", {"name": "Assign Worker", "worker_id": f"AW-{ts}", "role": "Fabricator", "box_id": 3, "is_active": True})
_, m_assign_res = log_req_res("POST", f"{BASE_URL}/machines/", {"name": "Assign Machine", "machine_id": f"AM-{ts}", "machine_number": f"SNA-{ts}", "category": "Drill", "status": "Available", "is_active": True})

if w_assign_res and m_assign_res:
    w_id2 = w_assign_res.get("id")
    m_id2 = m_assign_res.get("id")

    # Perform active assignment
    status_assign, a_res = log_req_res("POST", f"{BASE_URL}/assignments/assign", {"worker_id": w_id2, "machine_id": m_id2, "location": "On Site"})
    
    # Try concurrent/duplicate assignment on same machine (should return 409 Conflict)
    _, w3_res = log_req_res("POST", f"{BASE_URL}/workers/", {"name": "Worker 3", "worker_id": f"W3-{ts}", "role": "Fabricator", "box_id": 3, "is_active": True})
    if w3_res:
        w3_id = w3_res.get("id")
        log_req_res("POST", f"{BASE_URL}/assignments/assign", {"worker_id": w3_id, "machine_id": m_id2, "location": "On Site"})

    # Try manual status change of an assigned machine to Available (should fail with 400)
    log_req_res("PATCH", f"{BASE_URL}/machines/{m_id2}/status", {"status": "Available"})

    # Try manual status change to an invalid status (should fail with 422 validation)
    log_req_res("PATCH", f"{BASE_URL}/machines/{m_id2}/status", {"status": "Broken"})

    # Try deactivating worker with active assignment (should fail with 400)
    log_req_res("DELETE", f"{BASE_URL}/workers/{w_id2}")

    # Try deactivating machine with active assignment (should fail with 400)
    log_req_res("DELETE", f"{BASE_URL}/machines/{m_id2}")

    # Read current assignments
    log_req_res("GET", f"{BASE_URL}/assignments/current")

    if status_assign in (200, 201) and a_res:
        a_id = a_res.get("id")
        log_req_res("PATCH", f"{BASE_URL}/assignments/{a_id}/location", {"location": "With Worker"})
        log_req_res("PATCH", f"{BASE_URL}/assignments/{a_id}/location", {"location": "Invalid Location"})
        log_req_res("POST", f"{BASE_URL}/assignments/{a_id}/return")
        # Location update after return should fail
        log_req_res("PATCH", f"{BASE_URL}/assignments/{a_id}/location", {"location": "On Site"})
        
        # Read history (should show completed assignment with attribution names)
        log_req_res("GET", f"{BASE_URL}/assignments/history")

# 4. Dashboard
log_lines.append("\n=== DASHBOARD ===")
log_req_res("GET", f"{BASE_URL}/dashboard/stats")

# 5. Search
log_lines.append("\n=== SEARCH ===")
log_req_res("GET", f"{BASE_URL}/search/?q=Assign")

with open("authenticated_audit_results.txt", "w") as f:
    f.write("\n".join(log_lines))

print("Authenticated audit tests run complete. Results saved in authenticated_audit_results.txt")
