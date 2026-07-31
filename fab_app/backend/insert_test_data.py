from backend.infrastructure.database import SessionLocal
from backend.domain.models import Floor, Mestri, Box, Worker, Machine

def run():
    db = SessionLocal()
    
    # 1. Floor
    floor = Floor(name="Ground Floor")
    db.add(floor)
    db.commit()
    db.refresh(floor)

    # 2. Mestri
    mestri = Mestri(name="John Mestri", floor_id=floor.id)
    db.add(mestri)
    db.commit()
    db.refresh(mestri)

    # 3. Box
    box = Box(name="Box A", mestri_id=mestri.id)
    db.add(box)
    db.commit()
    db.refresh(box)

    # 4. Worker
    worker = Worker(name="Alice Worker", worker_id="W-123", role="Fabricator", is_active=True, box_id=box.id)
    db.add(worker)

    # 5. Machines
    machine1 = Machine(machine_id="M-101", machine_number="101", name="Welder 1", category="Welding", status="Available", is_active=True)
    machine2 = Machine(machine_id="M-102", machine_number="102", name="Drill 1", category="Drilling", status="Available", is_active=True)
    db.add_all([machine1, machine2])
    
    db.commit()
    print("Test data inserted successfully!")

if __name__ == "__main__":
    run()
