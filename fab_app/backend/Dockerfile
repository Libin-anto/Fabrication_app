FROM python:3.11-slim

WORKDIR /app

# Install system dependencies if required for psycopg2 or other libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/backend/

# Set environment variables
ENV PYTHONPATH=/app
ENV MODULE_NAME=backend.main
ENV VARIABLE_NAME=app

# Command to run the application using Gunicorn
CMD ["gunicorn", "-c", "backend/gunicorn_conf.py", "backend.main:app"]
