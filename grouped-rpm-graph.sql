-- Populate the grouped edge table after schema.sql, inventory and projected-graphs.sql.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
CREATE OR REPLACE VIEW pgdep_rpm_grouped_v AS
SELECT source_id, target_id,
       COUNT(DISTINCT capability_name) AS capability_count,
       LISTAGG(DISTINCT capability_name, ', ' ON OVERFLOW TRUNCATE '...' WITH COUNT)
         WITHIN GROUP (ORDER BY capability_name) AS capabilities
FROM pgdep_rpm_dependency_v
GROUP BY source_id, target_id;

INSERT INTO pgdep_rpm_grouped_edge (edge_id, source_id, target_id, capability_count, capabilities)
SELECT RAWTOHEX(STANDARD_HASH(source_id || ':' || target_id, 'SHA256')),
       source_id, target_id, capability_count, capabilities
FROM pgdep_rpm_grouped_v;
COMMIT;
