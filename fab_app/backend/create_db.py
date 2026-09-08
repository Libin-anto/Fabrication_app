import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from backend.domain.models import Base
from backend.infrastructure.database import engine

print("Creating database tables...")
Base.metadata.create_all(bind=engine)
print("Tables created successfully.")
