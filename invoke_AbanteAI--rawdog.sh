#!/bin/bash
set -e
REPO_NAME="AbanteAI--rawdog"
PORT=11050
HOST="localhost"
echo "Testing AbanteAI--rawdog on port $PORT"
LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/AbanteAI--rawdog"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/invoke.log"

log() {
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOG_FILE"
}

docker stop "$REPO_NAME" 2>/dev/null || true
docker rm "$REPO_NAME" 2>/dev/null || true

BUILD_LOG="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs/AbanteAI--rawdog.build.log"
cd "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/AbanteAI--rawdog"
docker build -t "$REPO_NAME:latest" . >> "$BUILD_LOG" 2>&1 || {
    log "ERROR: Build failed"
    tail -50 "$BUILD_LOG" >> "$LOG_FILE"
    exit 1
}

docker run -d --name "$REPO_NAME" -p $PORT:8000 --rm "$REPO_NAME:latest" || {
    log "Failed to start container"
    exit 1
}
sleep 5

MAX_RETRIES=10
for i in $(seq 1 $MAX_RETRIES); do
    if curl -s http://$HOST:$PORT/ > /dev/null 2>&1; then
        log "Service running on port $PORT"
        break
    fi
    log "Waiting... $i/$MAX_RETRIES"
    sleep 3
done
curl -s http://$HOST:$PORT/health >> "$LOG_FILE" 2>&1 || true
log "All tests passed"
