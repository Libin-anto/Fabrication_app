import urllib.request
import urllib.error
import json

BASE_URL = "http://localhost:8000"

def make_request(method, endpoint, data=None):
    url = f"{BASE_URL}{endpoint}"
    headers = {'Content-Type': 'application/json'}
    
    if data:
        data = json.dumps(data).encode('utf-8')
        
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    
    try:
        with urllib.request.urlopen(req) as response:
            return response.status, response.read().decode('utf-8')
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode('utf-8')

print("1. Register a second test account")
status, response = make_request("POST", "/auth/register", {"username": "test_user2", "password": "password123"})
print(f"Status: {status}\nResponse: {response}\n")

print("2. Login with the new test account")
status, response = make_request("POST", "/auth/login", {"username": "test_user2", "password": "password123"})
print(f"Status: {status}\nResponse: {response}\n")

print("3. Login with wrong password")
status, response = make_request("POST", "/auth/login", {"username": "test_user2", "password": "wrongpassword"})
print(f"Status: {status}\nResponse: {response}\n")

print("4. Login with the seeded 4105 account")
status, response = make_request("POST", "/auth/login", {"username": "4105", "password": "dhanush@123"})
print(f"Status: {status}\nResponse: {response}\n")
