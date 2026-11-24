WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
CREATE OR REPLACE PROPERTY GRAPH pg_dependencies
  VERTEX TABLES (pgdep_vertex KEY (id)
    LABEL dependency_node PROPERTIES (id, kind, name, version, detail))
  EDGE TABLES (pgdep_edge KEY (id)
    SOURCE KEY (source_id) REFERENCES pgdep_vertex (id)
    DESTINATION KEY (target_id) REFERENCES pgdep_vertex (id)
    LABEL dependency PROPERTIES (id, source_id, target_id, kind, detail));
