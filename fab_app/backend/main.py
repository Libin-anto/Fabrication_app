from fastapi import FastAPI
from backend.api import worker_router, machine_router, assignment_router, search_router, dashboard_router

app = FastAPI(title="Meerash Fab App API")

app.include_router(worker_router.router)
app.include_router(machine_router.router)
app.include_router(assignment_router.router)
app.include_router(search_router.router)
app.include_router(dashboard_router.router)

@app.get("/")
def root():
    return {"message": "Welcome to Meerash API"}
