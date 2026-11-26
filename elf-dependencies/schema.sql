WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
CREATE TABLE pg_elf_snapshot (
  id VARCHAR2(64) PRIMARY KEY,
  pg_version VARCHAR2(300), prefix_path VARCHAR2(2000) NOT NULL,
  bindir VARCHAR2(2000), pkglibdir VARCHAR2(2000),
  architecture VARCHAR2(100), kernel VARCHAR2(300), collected_utc VARCHAR2(50),
  ld_library_path VARCHAR2(2000), note VARCHAR2(2000)
);
CREATE TABLE pg_elf_vertex (
  id VARCHAR2(64) PRIMARY KEY,
  snapshot_id VARCHAR2(64) NOT NULL REFERENCES pg_elf_snapshot(id),
  kind VARCHAR2(30) NOT NULL, name VARCHAR2(1000) NOT NULL,
  path VARCHAR2(2000), detail VARCHAR2(2000), category VARCHAR2(30), origin VARCHAR2(30), owner_package VARCHAR2(300)
);
CREATE TABLE pg_elf_edge (
  id VARCHAR2(64) PRIMARY KEY,
  snapshot_id VARCHAR2(64) NOT NULL REFERENCES pg_elf_snapshot(id),
  source_id VARCHAR2(64) NOT NULL REFERENCES pg_elf_vertex(id),
  target_id VARCHAR2(64) NOT NULL REFERENCES pg_elf_vertex(id),
  kind VARCHAR2(30) NOT NULL, via VARCHAR2(4000)
);
CREATE INDEX pg_elf_vertex_snapshot_ix ON pg_elf_vertex(snapshot_id, kind, name);
CREATE INDEX pg_elf_edge_source_ix ON pg_elf_edge(source_id);
CREATE PROPERTY GRAPH pg_elf_dependencies
  VERTEX TABLES (pg_elf_vertex KEY(id)
    LABEL dependency_node PROPERTIES(id, snapshot_id, kind, name, path, detail, category, origin, owner_package))
  EDGE TABLES (pg_elf_edge KEY(id)
    SOURCE KEY(source_id) REFERENCES pg_elf_vertex(id)
    DESTINATION KEY(target_id) REFERENCES pg_elf_vertex(id)
    LABEL dependency PROPERTIES(id, snapshot_id, source_id, target_id, kind, via));
