#!/bin/bash

set -euo pipefail

REDIS_HOST="${REDIS_HOST:-127.0.0.1}"
REDIS_PORT="${REDIS_PORT:-6380}"
UNITS_INDEX="${UNITS_INDEX:-idx:units:v3}"
SCHEDULE_INDEX="${SCHEDULE_INDEX:-idx:periods:schedule}"

echo "=================================================="
echo "Redis Stack Quick Status"
echo "=================================================="
echo "Endpoint: ${REDIS_HOST}:${REDIS_PORT}"
echo ""

if ! redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" ping >/dev/null 2>&1; then
    echo "Redis is not reachable on ${REDIS_HOST}:${REDIS_PORT}"
    exit 1
fi

echo "1. Connectivity: OK"
echo "2. Version:"
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" INFO server | grep -E "redis_version|redis_mode"
echo ""

echo "3. Modules:"
MODULES=$(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" MODULE LIST || true)
if [ -z "$MODULES" ]; then
    echo "No Redis modules are loaded."
    exit 1
fi
echo "$MODULES"
echo ""

if ! echo "$MODULES" | grep -qi "search"; then
    echo "RediSearch module is missing."
    exit 1
fi

echo "4. Index health:"
for INDEX in "$UNITS_INDEX" "$SCHEDULE_INDEX"; do
    if redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" FT.INFO "$INDEX" >/dev/null 2>&1; then
        echo "   OK $INDEX"
        redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" FT.INFO "$INDEX" | grep -E "num_docs|index_name" || true
    else
        echo "   MISSING $INDEX"
    fi
done
echo ""

echo "5. Key counts:"
echo "   Total keys: $(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" DBSIZE)"
echo "   Unit docs: $(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" --scan --pattern 'unit:*' | wc -l)"
echo "   Schedule docs: $(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" --scan --pattern 'period:schedule:*' | wc -l)"
echo ""

echo "6. Memory:"
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" INFO memory | grep -E "used_memory_human|used_memory_peak_human|mem_fragmentation_ratio"
echo ""

echo "Redis Stack quick status completed successfully."
