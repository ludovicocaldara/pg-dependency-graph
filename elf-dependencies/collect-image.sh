#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
image=${PG_IMAGE:-localhost/pg-deps:crb}
docker run --rm -i --network none --entrypoint python3 "$image" - --pg-config /usr/pgsql-18/bin/pg_config "$@" < collect.py
