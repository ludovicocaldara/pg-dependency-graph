-- Run once as the existing PG_ELF_DEPS owner before loading newer snapshots.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER TABLE pg_elf_vertex ADD (extension_names VARCHAR2(2000));
CREATE OR REPLACE PROPERTY GRAPH pg_elf_dependencies
  VERTEX TABLES (pg_elf_vertex KEY(id)
    LABEL dependency_node PROPERTIES(id, snapshot_id, kind, name, path, detail, extension_names))
  EDGE TABLES (pg_elf_edge KEY(id)
    SOURCE KEY(source_id) REFERENCES pg_elf_vertex(id)
    DESTINATION KEY(target_id) REFERENCES pg_elf_vertex(id)
    LABEL dependency PROPERTIES(id, snapshot_id, source_id, target_id, kind, via));
