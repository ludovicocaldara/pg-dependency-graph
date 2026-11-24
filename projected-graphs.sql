WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
CREATE OR REPLACE VIEW pgdep_rpm_dependency_v AS
SELECT req.id AS requires_edge_id,
       prov.id AS provider_edge_id,
       req.source_id AS source_id,
       prov.target_id AS target_id,
       capability.id AS capability_id,
       capability.name AS capability_name
FROM pgdep_edge req
JOIN pgdep_vertex src ON src.id = req.source_id AND src.kind = 'RPM'
JOIN pgdep_vertex capability ON capability.id = req.target_id AND capability.kind = 'CAPABILITY'
JOIN pgdep_edge prov ON prov.source_id = capability.id AND prov.kind = 'PROVIDED_BY'
JOIN pgdep_vertex dst ON dst.id = prov.target_id AND dst.kind = 'RPM'
WHERE req.kind = 'REQUIRES';

CREATE OR REPLACE VIEW pgdep_extension_library_v AS
SELECT packaged.id AS packaged_edge_id,
       req.id AS requires_edge_id,
       prov.id AS provider_edge_id,
       packaged.source_id AS source_id,
       prov.target_id AS target_id,
       owner.id AS owner_rpm_id,
       owner.name AS owner_rpm_name,
       capability.id AS capability_id,
       capability.name AS capability_name
FROM pgdep_edge packaged
JOIN pgdep_vertex ext ON ext.id = packaged.source_id AND ext.kind = 'EXTENSION'
JOIN pgdep_vertex owner ON owner.id = packaged.target_id AND owner.kind = 'RPM'
JOIN pgdep_edge req ON req.source_id = owner.id AND req.kind = 'REQUIRES'
JOIN pgdep_vertex capability ON capability.id = req.target_id AND capability.kind = 'CAPABILITY'
JOIN pgdep_edge prov ON prov.source_id = capability.id AND prov.kind = 'PROVIDED_BY'
JOIN pgdep_vertex provider ON provider.id = prov.target_id AND provider.kind = 'RPM'
WHERE packaged.kind = 'PACKAGED_IN';

CREATE OR REPLACE PROPERTY GRAPH pg_rpm_dependencies
  VERTEX TABLES (
    pgdep_vertex KEY (id) LABEL dependency_node
      PROPERTIES (id, kind, name, version, detail)
  )
  EDGE TABLES (
    pgdep_rpm_dependency_v KEY (requires_edge_id, provider_edge_id)
      SOURCE KEY (source_id) REFERENCES pgdep_vertex (id)
      DESTINATION KEY (target_id) REFERENCES pgdep_vertex (id)
      LABEL rpm_requires
      PROPERTIES (requires_edge_id, provider_edge_id, source_id, target_id,
                  capability_id, capability_name)
  );

CREATE OR REPLACE PROPERTY GRAPH pg_extension_libraries
  VERTEX TABLES (
    pgdep_vertex KEY (id) LABEL dependency_node
      PROPERTIES (id, kind, name, version, detail)
  )
  EDGE TABLES (
    pgdep_extension_library_v KEY (packaged_edge_id, requires_edge_id, provider_edge_id)
      SOURCE KEY (source_id) REFERENCES pgdep_vertex (id)
      DESTINATION KEY (target_id) REFERENCES pgdep_vertex (id)
      LABEL extension_requires_rpm
      PROPERTIES (packaged_edge_id, requires_edge_id, provider_edge_id,
                  source_id, target_id, owner_rpm_id, owner_rpm_name,
                  capability_id, capability_name)
  );
