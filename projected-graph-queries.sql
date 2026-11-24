-- RPM-to-RPM paths. Parallel edges can represent different capabilities.
SELECT * FROM GRAPH_TABLE (
  pg_deps.pg_rpm_dependencies
  MATCH (a IS dependency_node)-[e IS rpm_requires]->(b IS dependency_node)
  COLUMNS (vertex_id(a) AS source_id, edge_id(e) AS edge_id,
           vertex_id(b) AS dest_id, a.name AS source_rpm,
           b.name AS provider_rpm, e.capability_name AS capability)
) FETCH FIRST 100 ROWS ONLY;

-- Extension-to-provider-RPM paths. The capability and owning package are
-- properties of each derived edge.
SELECT * FROM GRAPH_TABLE (
  pg_deps.pg_extension_libraries
  MATCH (a IS dependency_node)-[e IS extension_requires_rpm]->(b IS dependency_node)
  COLUMNS (vertex_id(a) AS source_id, edge_id(e) AS edge_id,
           vertex_id(b) AS dest_id, a.name AS extension_name,
           b.name AS provider_rpm, e.owner_rpm_name AS extension_package,
           e.capability_name AS capability)
) FETCH FIRST 100 ROWS ONLY;

-- One grouped edge for each directly required RPM.
SELECT * FROM GRAPH_TABLE (
  pg_deps.pg_rpm_grouped
  MATCH (a IS dependency_node)-[e IS rpm_requires]->(b IS dependency_node)
  WHERE a.kind = 'RPM' AND a.name = 'postgresql18-server'
  COLUMNS (vertex_id(a) AS source_id, edge_id(e) AS edge_id,
           vertex_id(b) AS dest_id, a.name AS source_rpm,
           b.name AS required_rpm, e.capability_count AS capability_count,
           e.capabilities AS capabilities)
);
