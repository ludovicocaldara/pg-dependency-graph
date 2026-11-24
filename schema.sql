WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
CREATE TABLE pgdep_vertex (
  id VARCHAR2(64) PRIMARY KEY,
  kind VARCHAR2(30) NOT NULL,
  name VARCHAR2(1000) NOT NULL,
  version VARCHAR2(500),
  detail VARCHAR2(2000)
);
CREATE TABLE pgdep_edge (
  id VARCHAR2(64) PRIMARY KEY,
  source_id VARCHAR2(64) NOT NULL REFERENCES pgdep_vertex(id),
  target_id VARCHAR2(64) NOT NULL REFERENCES pgdep_vertex(id),
  kind VARCHAR2(30) NOT NULL,
  detail VARCHAR2(2000)
);
CREATE PROPERTY GRAPH pg_dependencies
  VERTEX TABLES (pgdep_vertex KEY (id)
    LABEL dependency_node PROPERTIES (id, kind, name, version, detail))
  EDGE TABLES (pgdep_edge KEY (id)
    SOURCE KEY (source_id) REFERENCES pgdep_vertex (id)
    DESTINATION KEY (target_id) REFERENCES pgdep_vertex (id)
    LABEL dependency PROPERTIES (id, source_id, target_id, kind, detail));
