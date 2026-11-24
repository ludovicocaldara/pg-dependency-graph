#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
name=pg-deps-oracle
password=$(cat .pg-deps-password)
[[ "$password" =~ ^[A-Za-z0-9]+$ ]] || exit 1
docker cp replace-graph.sql "$name":/tmp/pg-deps-replace-graph.sql
docker cp inventory-crb.sql "$name":/tmp/pg-deps-inventory-crb.sql
docker cp graph-queries.sql "$name":/tmp/pg-deps-queries.sql
printf 'SET VERIFY OFF ECHO OFF FEEDBACK OFF\nWHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK\nCONNECT pg_deps/"%s"@//localhost:1521/FREEPDB1\n@/tmp/pg-deps-replace-graph.sql\nDELETE FROM pgdep_edge;\nDELETE FROM pgdep_vertex;\n@/tmp/pg-deps-inventory-crb.sql\n@/tmp/pg-deps-queries.sql\n' "$password" | docker exec -i "$name" sqlplus -s /nolog
