#!/bin/bash
set -euo pipefail
: "${GRAPH_JDBC_URL:?Set GRAPH_JDBC_URL}"
python3 - <<'PY'
import os
from pathlib import Path
p=Path('/etc/oracle/graph/pgx.conf')
s=p.read_text()
old='<REPLACE-WITH-DATABASE-URL-TO-USE-FOR-AUTHENTICATION>'
if old not in s and os.environ['GRAPH_JDBC_URL'] not in s:
    raise SystemExit('Expected JDBC placeholder missing from pgx.conf; inspect the installed version before configuring it.')
url=os.environ['GRAPH_JDBC_URL']
if any(c in url for c in ('"','\\','\n','\r')):
    raise SystemExit('Unexpected JDBC URL characters')
p.write_text(s.replace(old,url))
PY
export JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:-} -Djavax.net.ssl.trustStore=/etc/oracle/graph/client-truststore.jks -Djavax.net.ssl.trustStorePassword=changeit"
exec /opt/oracle/graph/pgx/bin/start-server
