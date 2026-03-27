#!/bin/bash

set -euo pipefail

REDIS_HOST="${REDIS_HOST:-127.0.0.1}"
REDIS_PORT="${REDIS_PORT:-6380}"
UNITS_INDEX="${UNITS_INDEX:-idx:units:v3}"
SCHEDULE_INDEX="${SCHEDULE_INDEX:-idx:periods:schedule}"

echo "=========================================="
echo "Redis Stack / RediSearch Verification"
echo "=========================================="
echo "Endpoint: ${REDIS_HOST}:${REDIS_PORT}"
echo ""

echo "1. Connectivity"
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" ping
echo ""

echo "2. Server info"
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" INFO server | grep -E "redis_version|os|process_id|tcp_port"
echo ""

echo "3. Modules"
MODULES=$(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" MODULE LIST)
echo "$MODULES"
if ! echo "$MODULES" | grep -qi "search"; then
    echo ""
    echo "RediSearch module is required but was not found."
    echo "Start backend/docker-compose.redis-stack.yml or point the app to a Redis Stack instance."
    exit 1
fi
echo ""

echo "4. RediSearch indexes"
for INDEX in "$UNITS_INDEX" "$SCHEDULE_INDEX"; do
    echo "   Checking $INDEX"
    if redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" FT.INFO "$INDEX" >/dev/null 2>&1; then
        redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" FT.INFO "$INDEX" | grep -E "index_name|num_docs|hash_indexing_failures" || true
    else
        echo "   Index $INDEX does not exist yet."
    fi
done
echo ""

echo "5. Data footprint"
echo "   Total keys: $(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" DBSIZE)"
echo "   unit:* keys: $(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" --scan --pattern 'unit:*' | wc -l)"
echo "   period:schedule:* keys: $(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" --scan --pattern 'period:schedule:*' | wc -l)"
echo ""

echo "6. Performance snapshot"
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" INFO stats | grep -E "total_commands_processed|instantaneous_ops_per_sec|keyspace_hits|keyspace_misses"
echo ""
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" INFO memory | grep -E "used_memory_human|used_memory_peak_human|mem_fragmentation_ratio"
echo ""

echo "Verification completed successfully."
