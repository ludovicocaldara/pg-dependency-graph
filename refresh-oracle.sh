#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
name=pg-deps-oracle
password=$(cat .pg-deps-password)
[[ "$password" =~ ^[A-Za-z0-9]+$ ]] || exit 1
# Keep the base and grouped snapshot replacement in one transaction.
input=$(mktemp "${TMPDIR:-/tmp}/pg-deps-inventory.XXXXXX")
trap 'rm -f "$input"' EXIT
awk 'BEGIN { n=0 } /^[[:space:]]*COMMIT;[[:space:]]*$/ { n++; next } { print } END { if (n != 1) exit 1 }' inventory-crb.sql > "$input" || { echo 'Expected exactly one standalone COMMIT in inventory-crb.sql' >&2; exit 1; }
docker cp replace-graph.sql "$name":/tmp/pg-deps-replace-graph.sql
docker cp "$input" "$name":/tmp/pg-deps-inventory-crb-no-commit.sql
docker cp graph-queries.sql "$name":/tmp/pg-deps-queries.sql
{
  printf 'SET VERIFY OFF ECHO OFF FEEDBACK OFF\nWHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK\nCONNECT pg_deps/"%s"@//localhost:1521/FREEPDB1\n' "$password"
  cat <<'SQL'
@/tmp/pg-deps-replace-graph.sql
DECLARE
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM user_tables WHERE table_name = 'PGDEP_RPM_GROUPED_EDGE';
  IF n = 1 THEN EXECUTE IMMEDIATE 'DELETE FROM pgdep_rpm_grouped_edge'; END IF;
END;
/
DELETE FROM pgdep_edge;
DELETE FROM pgdep_vertex;
@/tmp/pg-deps-inventory-crb-no-commit.sql
DECLARE
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM user_tables WHERE table_name = 'PGDEP_RPM_GROUPED_EDGE';
  IF n = 1 THEN
    EXECUTE IMMEDIATE q'~INSERT INTO pgdep_rpm_grouped_edge
      (edge_id, source_id, target_id, capability_count, capabilities)
      SELECT RAWTOHEX(STANDARD_HASH(source_id || ':' || target_id, 'SHA256')),
             source_id, target_id, capability_count, capabilities
      FROM pgdep_rpm_grouped_v~';
  END IF;
END;
/
COMMIT;
@/tmp/pg-deps-queries.sql
SQL
} | docker exec -i "$name" sqlplus -s /nolog
