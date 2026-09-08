import urllib.request
import urllib.error
import json
import sys

BASE_URL = "http://127.0.0.1:8000"

def print_curl(method, endpoint, json_data=None):
    url = f"{BASE_URL}{endpoint}"
    curl_cmd = f"curl -X {method} {url}"
    if json_data:
        curl_cmd += f" -H 'Content-Type: application/json' -d '{json.dumps(json_data)}'"
    print(f"> {curl_cmd}")

def run_step(step_name, method, endpoint, json_data=None):
    print(f"\n**{step_name}**")
    print_curl(method, endpoint, json_data)
    url = f"{BASE_URL}{endpoint}"
    
    req = urllib.request.Request(url, method=method)
    if json_data:
        data = json.dumps(json_data).encode('utf-8')
        req.add_header('Content-Type', 'application/json')
        req.data = data
        
    try:
        with urllib.request.urlopen(req) as response:
            status = response.status
            reason = response.reason
            body = response.read().decode('utf-8')
            print(f"{status} {reason}")
            print(body)
            if status >= 400:
                print(f"\nSTOPPING EXECUTION. Step {step_name} failed.")
                sys.exit(1)
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8')
        print(f"{e.code} {e.reason}")
        print(body)
        print(f"\nSTOPPING EXECUTION. Step {step_name} failed.")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

# a. GET /health
run_step("a. GET /health", "GET", "/health")

# b. GET /workers/
run_step("b. GET /workers/", "GET", "/workers/")

# c. POST /workers/
worker_data = {
    "name": "Test Worker",
    "worker_id": "TW-999",
    "role": "Helper",
    "is_active": True,
    "box_id": 3
}
res_c = run_step("c. POST /workers/", "POST", "/workers/", worker_data)
worker_db_id = res_c.get("id")

# d. GET /machines/?status=Available
machines = run_step("d. GET /machines/?status=Available", "GET", "/machines/?status=Available")
if not machines:
    print("No available machines found to assign. Creating a dummy machine...")
    dummy_machine = {
        "machine_id": "TM-999",
        "machine_number": "M-999",
        "name": "Test Machine",
        "category": "Test",
        "status": "Available",
        "is_active": True
    }
    m_res = run_step("POST /machines/ (helper step)", "POST", "/machines/", dummy_machine)
    machine_db_id = m_res.get("id")
else:
    machine_db_id = machines[0].get("id")

# e. POST /assignments/assign
assign_data = {
    "worker_id": worker_db_id,
    "machine_id": machine_db_id
}
res_e = run_step("e. POST /assignments/assign", "POST", "/assignments/assign", assign_data)
assignment_id = res_e.get("id")

# f. GET /assignments/current
run_step("f. GET /assignments/current", "GET", "/assignments/current")

# g. POST /assignments/{id}/return
run_step(f"g. POST /assignments/{assignment_id}/return", "POST", f"/assignments/{assignment_id}/return")

# h. GET /assignments/history
run_step("h. GET /assignments/history", "GET", "/assignments/history")

# i. DELETE /workers/{id}
run_step(f"i. DELETE /workers/{worker_db_id}", "DELETE", f"/workers/{worker_db_id}")

print("\nALL 9 STEPS PASSED!")
