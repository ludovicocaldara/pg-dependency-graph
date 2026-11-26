-- Run once on an existing PG_ELF_DEPS schema. The legacy extension_names
-- column remains for old data, but is not used by the new graph or collector.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER TABLE pg_elf_vertex ADD (
  category VARCHAR2(30), origin VARCHAR2(30), owner_package VARCHAR2(300)
);
CREATE OR REPLACE PROPERTY GRAPH pg_elf_dependencies
  VERTEX TABLES (pg_elf_vertex KEY(id)
    LABEL dependency_node PROPERTIES(id, snapshot_id, kind, name, path, detail, category, origin, owner_package))
  EDGE TABLES (pg_elf_edge KEY(id)
    SOURCE KEY(source_id) REFERENCES pg_elf_vertex(id)
    DESTINATION KEY(target_id) REFERENCES pg_elf_vertex(id)
    LABEL dependency PROPERTIES(id, snapshot_id, source_id, target_id, kind, via));
