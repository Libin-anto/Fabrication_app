from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.api import worker_router, machine_router, assignment_router, search_router, dashboard_router

app = FastAPI(title="Meerash Fab App API")

# Allow CORS for Vercel Frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173", 
        "http://localhost:3000",
        "https://fabrication-app-chi.vercel.app",
        "https://fabrication-87g7exd2g-teamthunder.vercel.app"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(worker_router.router)
app.include_router(machine_router.router)
app.include_router(assignment_router.router)
app.include_router(search_router.router)
app.include_router(dashboard_router.router)

@app.get("/")
def root():
    return {"message": "Welcome to Meerash API"}
