#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
container=${ORACLE_CONTAINER:-pg-deps-oracle}
inventory=${1:-output/inventory.sql}
[[ -f "$inventory" ]] || { echo "Inventory not found: $inventory" >&2; exit 1; }
if [[ ! -f .pg-elf-password ]]; then
  umask 077
  python3 -c 'import secrets; print("PgElf" + secrets.token_hex(16) + "9")' > .pg-elf-password
fi
password=$(cat .pg-elf-password)
[[ "$password" =~ ^[A-Za-z0-9]+$ ]] || { echo 'Invalid password file' >&2; exit 1; }
# Fresh schema only; never reset an existing user or remove existing data.
printf 'SET VERIFY OFF ECHO OFF FEEDBACK OFF\nWHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK\nALTER SESSION SET CONTAINER = FREEPDB1;\nCREATE USER pg_elf_deps IDENTIFIED BY "%s";\nGRANT CREATE SESSION, CREATE TABLE, CREATE PROPERTY GRAPH TO pg_elf_deps;\nALTER USER pg_elf_deps QUOTA UNLIMITED ON USERS;\nEXIT\n' "$password" | docker exec -i "$container" sqlplus -s / as sysdba
{ printf 'SET VERIFY OFF ECHO OFF FEEDBACK OFF\nWHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK\nCONNECT pg_elf_deps/"%s"@//localhost:1521/FREEPDB1\n' "$password"; cat schema.sql "$inventory"; printf '\nEXIT\n'; } | docker exec -i "$container" sqlplus -s /nolog
