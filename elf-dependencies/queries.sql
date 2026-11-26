-- Choose a snapshot, then locate a root or an extension.
SELECT id, pg_version, prefix_path, collected_utc FROM pg_elf_snapshot ORDER BY collected_utc DESC;
SELECT kind, name, category, origin, owner_package, path
FROM pg_elf_vertex WHERE snapshot_id = :snapshot_id
  AND kind IN ('POSTGRES_BINARY', 'PG_LIBRARY', 'EXTENSION') ORDER BY kind, name;

-- Visualize the server executable and its dependencies, up to three steps.
SELECT DISTINCT source_id, dest_id, edge_id
FROM GRAPH_TABLE (
  pg_elf_dependencies
  MATCH (root IS dependency_node)-[IS dependency]->{1,3}(finish IS dependency_node)
  WHERE root.snapshot_id = :snapshot_id
    AND root.kind = 'POSTGRES_BINARY'
    AND root.name = 'postgres'
  ONE ROW PER STEP (source, dependency, destination)
  COLUMNS (
    VERTEX_ID(source) AS source_id,
    VERTEX_ID(destination) AS dest_id,
    EDGE_ID(dependency) AS edge_id
  )
);

-- Visualize every edge in the collected PostgreSQL snapshot.
SELECT *
FROM GRAPH_TABLE (
  pg_elf_dependencies
  MATCH (source IS dependency_node)-[edge IS dependency]->(destination IS dependency_node)
  WHERE source.snapshot_id = :snapshot_id
  COLUMNS (
    VERTEX_ID(source) AS source_id,
    VERTEX_ID(destination) AS dest_id,
    EDGE_ID(edge) AS edge_id
  )
);

-- Normalized extension-to-library lookup (several extensions can use a library).
SELECT e.name AS extension_name, l.name AS library_name,
       l.category, l.origin, l.owner_package, l.path
FROM pg_elf_vertex e
JOIN pg_elf_edge rel ON rel.source_id = e.id AND rel.kind = 'USES_LIBRARY'
JOIN pg_elf_vertex l ON l.id = rel.target_id
WHERE e.snapshot_id = :snapshot_id AND e.kind = 'EXTENSION'
  AND e.name = :extension_name
ORDER BY l.name;

-- SQL Developer Graph Visualization: start at an extension, follow the library
-- association and its external dependencies. The bound limits path expansion.
SELECT * FROM GRAPH_TABLE (
  pg_elf_dependencies
  MATCH (root IS dependency_node)-[IS dependency]->{1,4}(finish IS dependency_node)
  WHERE root.snapshot_id = :snapshot_id AND root.kind = 'EXTENSION'
    AND root.name = :extension_name
  ONE ROW PER STEP (source, dependency, destination)
  COLUMNS (vertex_id(source) AS source_id,
           vertex_id(destination) AS dest_id,
           edge_id(dependency) AS edge_id)
);

-- Alternatively start at a binary or library's full path.
SELECT * FROM GRAPH_TABLE (
  pg_elf_dependencies
  MATCH (root IS dependency_node)-[IS dependency]->{1,3}(finish IS dependency_node)
  WHERE root.snapshot_id = :snapshot_id AND root.path = :root_path
  ONE ROW PER STEP (source, dependency, destination)
  COLUMNS (vertex_id(source) AS source_id,
           vertex_id(destination) AS dest_id,
           edge_id(dependency) AS edge_id)
);

SELECT name, detail FROM pg_elf_vertex WHERE snapshot_id = :snapshot_id AND kind = 'UNRESOLVED' ORDER BY name;
