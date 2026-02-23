FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN pip install --no-cache-dir litellm fastapi uvicorn pydantic

# Copy source
COPY src/ ./src/
COPY pyproject.toml .

# Copy HTTP server
COPY http_server.py /app/http_server.py

EXPOSE 8000
CMD ["python", "/app/http_server.py"]
