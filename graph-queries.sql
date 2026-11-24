WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET LINESIZE 200 PAGESIZE 100
PROMPT Vertex types
SELECT kind, COUNT(*) AS vertices FROM pgdep_vertex GROUP BY kind ORDER BY kind;
PROMPT Relationship types
SELECT kind, COUNT(*) AS edges FROM pgdep_edge GROUP BY kind ORDER BY kind;
PROMPT Graph query: vertex and edge IDs
SELECT * FROM GRAPH_TABLE (pg_dependencies
  MATCH (a IS dependency_node)-[r IS dependency]->(b IS dependency_node)
  COLUMNS (a.id AS vertex_id, r.id AS edge_id, r.source_id AS source_id,
           r.target_id AS target_id, b.id AS target_vertex_id))
  FETCH FIRST 3 ROWS ONLY;
PROMPT Graph query: extensions and owning RPMs
SELECT * FROM GRAPH_TABLE (pg_dependencies
  MATCH (e IS dependency_node)-[r IS dependency]->(p IS dependency_node)
  WHERE e.kind = 'EXTENSION' AND r.kind = 'PACKAGED_IN'
  COLUMNS (e.name AS extension_name, p.name AS rpm_name))
  FETCH FIRST 10 ROWS ONLY;
PROMPT Graph query: extension prerequisites
SELECT * FROM GRAPH_TABLE (pg_dependencies
  MATCH (a IS dependency_node)-[r IS dependency]->(b IS dependency_node)
  WHERE r.kind = 'REQUIRES_EXTENSION'
  COLUMNS (a.name AS extension_name, b.name AS prerequisite))
  FETCH FIRST 10 ROWS ONLY;
PROMPT Graph query: package requirements and installed providers
SELECT * FROM GRAPH_TABLE (pg_dependencies
  MATCH (p IS dependency_node)-[r IS dependency]->(c IS dependency_node)-[s IS dependency]->(provider IS dependency_node)
  WHERE r.kind = 'REQUIRES' AND s.kind = 'PROVIDED_BY'
  COLUMNS (p.name AS rpm_name, c.name AS requirement, provider.name AS provider_name))
  FETCH FIRST 10 ROWS ONLY;
EXIT
