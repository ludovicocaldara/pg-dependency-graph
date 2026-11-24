#!/bin/bash
set -eu
mkdir -p /var/lib/pg-deps
# Discover packages built for the selected PostgreSQL major version. Attempt each
# independently so unavailable dependencies do not abort the whole inventory.
dnf repoquery --available --qf '%{name}' | sort -u | awk -v suffix="_${PG_MAJOR}" 'length($0)>=length(suffix) && substr($0,length($0)-length(suffix)+1)==suffix && $0 !~ /(-debuginfo|-debugsource|-devel|_llvmjit)/' > /var/lib/pg-deps/candidates.txt
: > /var/lib/pg-deps/failed.txt
while IFS= read -r pkg; do
  if ! dnf -y install "$pkg" >> /var/lib/pg-deps/install.log 2>&1; then printf '%s\n' "$pkg" >> /var/lib/pg-deps/failed.txt; fi
done < /var/lib/pg-deps/candidates.txt
dnf clean all
