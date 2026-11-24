#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
name=pg-deps-oracle
if [[ ! -f .pg-deps-password ]]; then
  umask 077
  python3 -c 'import secrets; print("PgD" + secrets.token_hex(16) + "9")' > .pg-deps-password
fi
password=$(cat .pg-deps-password)
[[ "$password" =~ ^[A-Za-z0-9]+$ ]] || exit 1
# Copy only SQL input files into this dedicated container.
docker cp create-user.sql "$name":/tmp/pg-deps-create-user.sql
docker cp schema.sql "$name":/tmp/pg-deps-schema.sql
docker cp inventory-crb.sql "$name":/tmp/pg-deps-inventory.sql
docker cp graph-queries.sql "$name":/tmp/pg-deps-queries.sql
docker cp projected-graphs.sql "$name":/tmp/pg-deps-projected-graphs.sql
docker cp grouped-rpm-graph.sql "$name":/tmp/pg-deps-grouped-rpm-graph.sql
# This setup is intentionally fresh-only: CREATE USER fails if the user exists.
printf 'SET VERIFY OFF ECHO OFF FEEDBACK OFF\nWHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK\n@/tmp/pg-deps-create-user.sql %s\n' "$password" | docker exec -i "$name" sqlplus -s / as sysdba
printf 'SET VERIFY OFF ECHO OFF FEEDBACK OFF\nWHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK\nCONNECT pg_deps/"%s"@//localhost:1521/FREEPDB1\n@/tmp/pg-deps-schema.sql\n@/tmp/pg-deps-inventory.sql\n@/tmp/pg-deps-projected-graphs.sql\n@/tmp/pg-deps-grouped-rpm-graph.sql\n@/tmp/pg-deps-queries.sql\n' "$password" | docker exec -i "$name" sqlplus -s /nolog
