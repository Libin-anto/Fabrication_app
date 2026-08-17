from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.api import worker_router, machine_router, assignment_router, search_router, dashboard_router

app = FastAPI(title="Meerash Fab App API")

# Allow CORS for Vercel Frontend and Local Expo Dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://fabrication-app-chi.vercel.app",
        "https://fabrication-87g7exd2g-teamthunder.vercel.app",
        "http://localhost:8081",
        "http://localhost:19006",
        "http://192.168.137.1:8081",
        "http://localhost:5173", # Re-adding standard Vite local port just in case
        "http://localhost:3000"
    ],
    allow_origin_regex=r"https://fabrication-.*\.vercel\.app",
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

@app.get("/health")
def health_check():
    return {"status": "ok"}
