SELECT *
FROM GRAPH_TABLE (
  pg_dependencies
  MATCH (source )
        -[edge ]->
        (destination )
  COLUMNS (
    vertex_id(source)      AS source_id,
    vertex_id(destination) AS dest_id,
    edge_id(edge)        AS edge_id
  )
)
fetch first 10 rows only;