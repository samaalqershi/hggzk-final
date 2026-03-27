# Redis Stack Setup

This project supports two search providers:

- `Postgres`: the stable default provider.
- `Redis`: an accelerated provider that requires Redis Stack with the RediSearch module.

## Development runtime

Development is wired to Redis Stack on `127.0.0.1:6380` to avoid colliding with a plain local Redis instance on `6379`.

Files involved:

- [appsettings.Development.json](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Api/appsettings.Development.json)
- [docker-compose.redis-stack.yml](/home/ameen/Desktop/myProjects/Rezmate/backend/docker-compose.redis-stack.yml)
- [start_redis_stack.sh](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Api/start_redis_stack.sh)
- [verify_redis.sh](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Api/verify_redis.sh)

## Start Redis Stack

```bash
cd backend/hggzk.Api
./start_redis_stack.sh
```

## Verify RediSearch

```bash
cd backend/hggzk.Api
./verify_redis.sh
```

The verification must show:

- the `search` module in `MODULE LIST`
- `idx:units:v3`
- `idx:periods:schedule`

## Run the API with Redis search

```bash
ASPNETCORE_ENVIRONMENT=Development \
SearchEngine__Provider=Redis \
dotnet run --project backend/hggzk.Api/hggzk.Api.csproj
```

If RediSearch is missing, startup now fails fast with a clear error instead of returning silent empty results.
