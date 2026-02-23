#!/bin/bash
set -e
echo "Starting AbanteAI--rawdog HTTP service..."
cd /app
exec python /app/http_server.py
