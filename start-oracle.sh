#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
name=pg-deps-oracle
image=container-registry.oracle.com/database/free:latest
if docker container inspect "$name" >/dev/null 2>&1; then
  echo "Container $name already exists; start it with docker start $name if needed." >&2; exit 1
fi
if [[ ! -f .oracle-password ]]; then
  umask 077
  python3 -c 'import secrets; print("PgD" + secrets.token_hex(16) + "9")' > .oracle-password
fi
password=$(cat .oracle-password)
if [[ ! "$password" =~ ^[A-Za-z0-9]+$ ]]; then echo 'Password must contain only letters and digits.' >&2; exit 1; fi
docker pull "$image"
docker run -d --name "$name" -p 127.0.0.1:15219:1521 -v pg-deps-oracle-data:/opt/oracle/oradata -e ORACLE_PWD="$password" "$image"
echo 'Waiting for the database to become ready (up to 15 minutes)...'
for ((i=0;i<180;i++)); do
  if docker logs "$name" 2>&1 | grep 'DATABASE IS READY TO USE' >/dev/null; then echo 'Database ready.'; exit 0; fi
  if [[ "$(docker inspect -f '{{.State.Running}}' "$name")" != true ]]; then docker logs --tail 80 "$name"; exit 1; fi
  sleep 5
done
echo 'Database did not become ready; inspect: docker logs pg-deps-oracle' >&2; exit 1
