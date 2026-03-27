#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${BACKEND_DIR}/docker-compose.redis-stack.yml"

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required to start Redis Stack."
    exit 1
fi

echo "Starting Redis Stack using ${COMPOSE_FILE}"
docker compose -f "${COMPOSE_FILE}" up -d
echo ""
echo "Redis Stack is starting on:"
echo "  Redis:        127.0.0.1:6380"
echo "  RedisInsight: http://127.0.0.1:8002"
echo ""
echo "Run ./verify_redis.sh after a few seconds to confirm RediSearch readiness."
