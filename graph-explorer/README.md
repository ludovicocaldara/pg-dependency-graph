# Graph Explorer container

This container is a fallback. The recommended visualization workflow is the VS Code extension described in the [project README](../README.md); version 26.4.3 worked in this environment, while 26.4.4 reported a worksheet-change error.

Oracle Graph Server 26.4.1 runs in a separate ARM64 container and connects to the existing Oracle Free database through `host.containers.internal:15219/FREEPDB1`. Graph Studio is available at `https://localhost:7007/graphstudio/`, bound to the Mac's loopback interface.

The Oracle database user `PG_DEPS` has been granted `GRAPH_DEVELOPER` in `FREEPDB1`, per Oracle's Graph Server documentation. Sign in with that user and the password in `../.pg-deps-password`. In Graph Explorer, expand **SQL Property Graphs > PG_DEPS > PG_DEPENDENCIES**, select the SQL driver, and use **Visualize Graph**. For example:

```sql
SELECT * FROM GRAPH_TABLE (
  pg_deps.pg_dependencies
  MATCH (a IS dependency_node)-[e IS dependency]->(b IS dependency_node)
  COLUMNS (vertex_id(a) AS id_a, edge_id(e) AS id_e, vertex_id(b) AS id_b)
) FETCH FIRST 10 ROWS ONLY
```

The Graph Server installation generates a self-signed certificate for localhost. The server's own Java trust store trusts that certificate; a browser may display a certificate warning. Configure the browser or macOS to trust an appropriate certificate, or decide how to handle the warning yourself. The default keystore password and generated certificate are suitable only for this local development setup.

## Start and stop

```sh
docker start pg-deps-oracle
docker start pg-deps-graph-explorer
docker logs -f pg-deps-graph-explorer
# Stop Graph Explorer without deleting the database
docker stop pg-deps-graph-explorer
```

To build a new image, place the Oracle Graph Server 26.4.1 ARM64 RPM here with the name `oracle-graph-26.4.1.aarch64.rpm`, then run:

```sh
docker build -t pg-deps-graph-explorer .
docker run -d --name pg-deps-graph-explorer \
  -p 127.0.0.1:7007:7007 \
  -e GRAPH_JDBC_URL='jdbc:oracle:thin:@host.containers.internal:15219/FREEPDB1' \
  pg-deps-graph-explorer
```

The `docker run` command creates a new named container; if one already exists, use `docker start` instead. The image generates a local certificate during build. Oracle's package is distributed under its applicable license terms; it and the provided ZIP files should not be committed.

The existing `pg-deps-graph-explorer:latest` image includes the trust-store fix and was verified in a second temporary container. A full rebuild of the original Dockerfile ran out of container storage; `Dockerfile.configure` was used to add the fix to the already-built image. The service was checked using the Graph Server REST API: authentication succeeded, the graph was listed, and a SQL graph visualization query returned 15 vertices and 10 edges. Browser visualization has not been checked.

References: [Graph Server installation](https://docs.oracle.com/en/database/oracle/property-graph/26.4/spgdg/using-rpm-installation.html), [database authentication](https://docs.oracle.com/en/database/oracle/property-graph/26.4/spgdg/user-authentication-and-authorization.html), and [Graph Explorer](https://docs.oracle.com/en/database/oracle/property-graph/26.4/spgdg/querying-and-visualizing-sql-property-graphs.html).
