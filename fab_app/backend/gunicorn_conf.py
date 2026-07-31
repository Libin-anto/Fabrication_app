import multiprocessing
import os

# Gunicorn config variables
loglevel = os.getenv("LOG_LEVEL", "info")
workers = int(os.getenv("WORKERS", multiprocessing.cpu_count() * 2 + 1))
port = os.getenv("PORT", "8000")
bind = os.getenv("BIND", f"0.0.0.0:{port}")
worker_class = "uvicorn.workers.UvicornWorker"
keepalive = 120
errorlog = "-"
accesslog = "-"
