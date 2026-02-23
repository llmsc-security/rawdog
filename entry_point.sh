#!/bin/bash
set -e

echo "Starting AbanteAI--rawdog HTTP service..."
echo "Current time: $(date)"

exec python /app/http_server.py
