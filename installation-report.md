# PostgreSQL extension installation report

Snapshot of `pg-deps:latest` with Rocky Linux 9, PostgreSQL 18 and ARM64, rebuilt on 24 November 2026 with the Rocky Linux CRB repository enabled. The installer attempts available RPM names ending in `_18`. Availability varies by system, architecture, PostgreSQL version and repository state.

- 160 candidate RPMs attempted; 157 are installed and 3 failed.
- 208 extension control files are present, including PostgreSQL contrib. One RPM can contain several extensions.
- A control file indicates availability for `CREATE EXTENSION`; it does not prove the extension was created or tested in PostgreSQL.

A temporary PostgreSQL 18 instance successfully ran `CREATE EXTENSION` for `postgis`, `postgis_raster`, `postgis_topology`, `address_standardizer`, `ogr_fdw`, `pointcloud`, and `pgmemcache`. This validates creation, not all functionality or external service connectivity.

## Failed package attempts

| Package | Cause |
| --- | --- |
| `postgis33_18` | Conflicts with files owned by the installed `postgis37_18`; choose one PostGIS release for this PostgreSQL installation. |
| `postgis35_18` | Conflicts with files owned by the installed `postgis37_18`; choose one PostGIS release for this PostgreSQL installation. |
| `postgis36_18` | Conflicts with files owned by the installed `postgis37_18`; choose one PostGIS release for this PostgreSQL installation. |

Previously, `pgmemcache_18` lacked `libmemcached`, and GDAL lacked `libqhull_r.so.7`. Both providers are in Rocky Linux CRB, which was disabled. With CRB enabled, those libraries, GDAL, `pgmemcache_18`, PostGIS 3.7, `address_standardizer_18`, `ogr_fdw_18`, `pointcloud_18`, and `postgis_tiger_geocoder_18` installed successfully. `libmemcached` is a client library, not the memcached server.

## Installed candidate RPMs

`address_standardizer_18`, `age_18`, `babelfish_extensions_18`, `bgw_replstatus_18`, `biscuit_18`, `citus_18`, `count_distinct_18`, `credcheck_18`  
`datasketches_18`, `ddlx_18`, `e-maj_18`, `extra_window_functions_18`, `firebird_fdw_18`, `h3-pg_18`, `hdfs_fdw_18`, `hll_18`  
`hypopg_18`, `icu_ext_18`, `ip4r_18`, `jdbc_fdw_18`, `jsquery_18`, `logerrors_18`, `mongo_fdw_18`, `mysql_fdw_18`  
`nominatim_fdw_18`, `odbc_fdw_18`, `ogr_fdw_18`, `orafce_18`, `passwordcheck_cracklib_18`, `passwordpolicy_18`, `pg_auth_mon_18`, `pg_background_18`  
`pg_bigm_18`, `pg_bulkload_18`, `pg_catcheck_18`, `pg_checksums_18`, `pg_cron_18`, `pg_csv_18`, `pg_curl_18`, `pg_dbms_errlog_18`  
`pg_dbms_job_18`, `pg_dbms_lock_18`, `pg_dbms_metadata_18`, `pg_dirtyread_18`, `pg_extra_time_18`, `pg_failover_slots_18`, `pg_filedump_18`, `pg_fkpart_18`  
`pg_hint_plan_18`, `pg_incremental_18`, `pg_ivm_18`, `pg_jobmon_18`, `pg_kpart_18`, `pg_oidc_validator_18`, `pg_parquet_18`, `pg_partman_18`  
`pg_permissions_18`, `pg_plan_filter_18`, `pg_prioritize_18`, `pg_profile_18`, `pg_pwhash_18`, `pg_qualstats_18`, `pg_readme_18`, `pg_readonly_18`  
`pg_repack_18`, `pg_rewrite_18`, `pg_roaringbitmap_18`, `pg_show_plans_18`, `pg_similarity_18`, `pg_snakeoil_18`, `pg_squeeze_18`, `pg_stat_kcache_18`  
`pg_stat_log_18`, `pg_stat_monitor_18`, `pg_stat_plans_18`, `pg_stat_tcpinfo_18`, `pg_statement_rollback_18`, `pg_statviz_extension_18`, `pg_store_plans_18`, `pg_task_18`  
`pg_textsearch_18`, `pg_tle_18`, `pg_track_settings_18`, `pg_utl_smtp_18`, `pg_uuidv7_18`, `pg_wait_sampling_18`, `pgagent_18`, `pgaudit_18`  
`pgauditlogtofile_18`, `pgbouncer_fdw_18`, `pgdisablelogerror_18`, `pgexportdoc_18`, `pgexporter_ext_18`, `pgextwlist_18`, `pgfaceting_18`, `pgimportdoc_18`  
`pglogical_18`, `pgmemcache_18`, `pgmeminfo_18`, `pgmp_18`, `pgmq_18`, `pgnodemx_18`, `pgpcre_18`, `pgpdf_18`  
`pgq_18`, `pgrouting_18`, `pgsentinel_18`, `pgsodium_18`, `pgsql_gzip_18`, `pgsql_http_18`, `pgsql_tweaks_18`, `pgstats_18`  
`pgtap_18`, `pgtt_18`, `pguint_18`, `pguri_18`, `pgvector_18`, `pgvectorscale_18`, `pgx-bm25_18`, `pldebugger_18`  
`pljava_18`, `plpgsql_check_18`, `plpgsql_wrap_18`, `plprofiler_18`, `plproxy_18`, `plr_18`, `plsh_18`, `plxslt_18`  
`pointcloud_18`, `postgis37_18`, `postgis_tiger_geocoder_18`, `postgres-decoderbufs_18`, `postgresbson_18`, `postgresql-numeral_18`, `postgresql-unit_18`, `postgresql_anonymizer_18`  
`postgresql_faker_18`, `powa-archivist_18`, `powa_18`, `prefix_18`, `q3c_18`, `rdf_fdw_18`, `repmgr_18`, `safeupdate_18`  
`semver_18`, `sequential_uuids_18`, `set_user_18`, `sslutils_18`, `system_stats_18`, `table_version_18`, `tdigest_18`, `tds_fdw_18`  
`timescaledb_18`, `timestamp9_18`, `toastinfo_18`, `topn_18`, `wal2json_18`  

## Available extension control files

| Extension | Owning RPM |
| --- | --- |
| `address_standardizer` | `address_standardizer_18` |
| `address_standardizer_data_us` | `address_standardizer_18` |
| `age` | `age_18` |
| `amcheck` | `postgresql18-contrib` |
| `anon` | `postgresql_anonymizer_18` |
| `autoinc` | `postgresql18-contrib` |
| `biscuit` | `biscuit_18` |
| `bloom` | `postgresql18-contrib` |
| `bm25_native` | `pgx-bm25_18` |
| `bool_plperl` | `postgresql18-plperl` |
| `bool_plperlu` | `postgresql18-plperl` |
| `btree_gin` | `postgresql18-contrib` |
| `btree_gist` | `postgresql18-contrib` |
| `citext` | `postgresql18-contrib` |
| `citus` | `citus_18` |
| `citus_columnar` | `citus_18` |
| `count_distinct` | `count_distinct_18` |
| `credcheck` | `credcheck_18` |
| `cube` | `postgresql18-contrib` |
| `datasketches` | `datasketches_18` |
| `dblink` | `postgresql18-contrib` |
| `ddlx` | `ddlx_18` |
| `decoderbufs` | `postgres-decoderbufs_18` |
| `dict_int` | `postgresql18-contrib` |
| `dict_xsyn` | `postgresql18-contrib` |
| `earthdistance` | `postgresql18-contrib` |
| `emaj` | `e-maj_18` |
| `extra_window_functions` | `extra_window_functions_18` |
| `faker` | `postgresql_faker_18` |
| `file_fdw` | `postgresql18-contrib` |
| `firebird_fdw` | `firebird_fdw_18` |
| `fuzzystrmatch` | `postgresql18-contrib` |
| `gzip` | `pgsql_gzip_18` |
| `h3` | `h3-pg_18` |
| `h3_postgis` | `h3-pg_18` |
| `hdfs_fdw` | `hdfs_fdw_18` |
| `hll` | `hll_18` |
| `hstore` | `postgresql18-contrib` |
| `hstore_plperl` | `postgresql18-contrib` |
| `hstore_plperlu` | `postgresql18-contrib` |
| `hstore_plpython3u` | `postgresql18-plpython3` |
| `http` | `pgsql_http_18` |
| `hypopg` | `hypopg_18` |
| `icu_ext` | `icu_ext_18` |
| `insert_username` | `postgresql18-contrib` |
| `intagg` | `postgresql18-contrib` |
| `intarray` | `postgresql18-contrib` |
| `ip4r` | `ip4r_18` |
| `isn` | `postgresql18-contrib` |
| `jdbc_fdw` | `jdbc_fdw_18` |
| `jsonb_plperl` | `postgresql18-contrib` |
| `jsonb_plperlu` | `postgresql18-contrib` |
| `jsonb_plpython3u` | `postgresql18-plpython3` |
| `jsquery` | `jsquery_18` |
| `lo` | `postgresql18-contrib` |
| `logerrors` | `logerrors_18` |
| `ltree` | `postgresql18-contrib` |
| `ltree_plpython3u` | `postgresql18-plpython3` |
| `moddatetime` | `postgresql18-contrib` |
| `mongo_fdw` | `mongo_fdw_18` |
| `mysql_fdw` | `mysql_fdw_18` |
| `nominatim_fdw` | `nominatim_fdw_18` |
| `numeral` | `postgresql-numeral_18` |
| `odbc_fdw` | `odbc_fdw_18` |
| `ogr_fdw` | `ogr_fdw_18` |
| `orafce` | `orafce_18` |
| `pageinspect` | `postgresql18-contrib` |
| `passwordpolicy` | `passwordpolicy_18` |
| `pg_auth_mon` | `pg_auth_mon_18` |
| `pg_background` | `pg_background_18` |
| `pg_bigm` | `pg_bigm_18` |
| `pg_buffercache` | `postgresql18-contrib` |
| `pg_bulkload` | `pg_bulkload_18` |
| `pg_cron` | `pg_cron_18` |
| `pg_csv` | `pg_csv_18` |
| `pg_curl` | `pg_curl_18` |
| `pg_dbms_errlog` | `pg_dbms_errlog_18` |
| `pg_dbms_job` | `pg_dbms_job_18` |
| `pg_dbms_lock` | `pg_dbms_lock_18` |
| `pg_dbms_metadata` | `pg_dbms_metadata_18` |
| `pg_dirtyread` | `pg_dirtyread_18` |
| `pg_extra_time` | `pg_extra_time_18` |
| `pg_fkpart` | `pg_fkpart_18` |
| `pg_freespacemap` | `postgresql18-contrib` |
| `pg_hint_plan` | `pg_hint_plan_18` |
| `pg_incremental` | `pg_incremental_18` |
| `pg_ivm` | `pg_ivm_18` |
| `pg_jobmon` | `pg_jobmon_18` |
| `pg_kpart` | `pg_kpart_18` |
| `pg_logicalinspect` | `postgresql18-contrib` |
| `pg_parquet` | `pg_parquet_18` |
| `pg_partman` | `pg_partman_18` |
| `pg_permissions` | `pg_permissions_18` |
| `pg_prewarm` | `postgresql18-contrib` |
| `pg_proctab` | `pgnodemx_18` |
| `pg_proctab--0.0.10-compat` | `pgnodemx_18` |
| `pg_profile` | `pg_profile_18` |
| `pg_pwhash` | `pg_pwhash_18` |
| `pg_qualstats` | `pg_qualstats_18` |
| `pg_readme` | `pg_readme_18` |
| `pg_readme_test_extension` | `pg_readme_18` |
| `pg_readonly` | `pg_readonly_18` |
| `pg_repack` | `pg_repack_18` |
| `pg_rewrite` | `pg_rewrite_18` |
| `pg_show_plans` | `pg_show_plans_18` |
| `pg_similarity` | `pg_similarity_18` |
| `pg_snakeoil` | `pg_snakeoil_18` |
| `pg_squeeze` | `pg_squeeze_18` |
| `pg_stat_kcache` | `pg_stat_kcache_18` |
| `pg_stat_log` | `pg_stat_log_18` |
| `pg_stat_monitor` | `pg_stat_monitor_18` |
| `pg_stat_plans` | `pg_stat_plans_18` |
| `pg_stat_statements` | `postgresql18-contrib` |
| `pg_stat_tcpinfo` | `pg_stat_tcpinfo_18` |
| `pg_statviz` | `pg_statviz_extension_18` |
| `pg_store_plans` | `pg_store_plans_18` |
| `pg_surgery` | `postgresql18-contrib` |
| `pg_textsearch` | `pg_textsearch_18` |
| `pg_tle` | `pg_tle_18` |
| `pg_track_settings` | `pg_track_settings_18` |
| `pg_trgm` | `postgresql18-contrib` |
| `pg_utl_smtp` | `pg_utl_smtp_18` |
| `pg_uuidv7` | `pg_uuidv7_18` |
| `pg_visibility` | `postgresql18-contrib` |
| `pg_wait_sampling` | `pg_wait_sampling_18` |
| `pg_walinspect` | `postgresql18-contrib` |
| `pgagent` | `pgagent_18` |
| `pgaudit` | `pgaudit_18` |
| `pgauditlogtofile` | `pgauditlogtofile_18` |
| `pgbouncer_fdw` | `pgbouncer_fdw_18` |
| `pgbson` | `postgresbson_18` |
| `pgcrypto` | `postgresql18-contrib` |
| `pgdisablelogerror` | `pgdisablelogerror_18` |
| `pgexporter_ext` | `pgexporter_ext_18` |
| `pgfaceting` | `pgfaceting_18` |
| `pglogical` | `pglogical_18` |
| `pglogical_origin` | `pglogical_18` |
| `pgmemcache` | `pgmemcache_18` |
| `pgmeminfo` | `pgmeminfo_18` |
| `pgmp` | `pgmp_18` |
| `pgmq` | `pgmq_18` |
| `pgnodemx` | `pgnodemx_18` |
| `pgpcre` | `pgpcre_18` |
| `pgpdf` | `pgpdf_18` |
| `pgq` | `pgq_18` |
| `pgrouting` | `pgrouting_18` |
| `pgrowlocks` | `postgresql18-contrib` |
| `pgsentinel` | `pgsentinel_18` |
| `pgsodium` | `pgsodium_18` |
| `pgsql_tweaks` | `pgsql_tweaks_18` |
| `pgstattuple` | `postgresql18-contrib` |
| `pgtap` | `pgtap_18` |
| `pgtt` | `pgtt_18` |
| `pldbgapi` | `pldebugger_18` |
| `pljava` | `pljava_18` |
| `plperl` | `postgresql18-plperl` |
| `plperlu` | `postgresql18-plperl` |
| `plpgsql` | `postgresql18-server` |
| `plpgsql_check` | `plpgsql_check_18` |
| `plpgsql_wrap` | `plpgsql_wrap_18` |
| `plprofiler` | `plprofiler_18-server` |
| `plproxy` | `plproxy_18` |
| `plpython3u` | `postgresql18-plpython3` |
| `plr` | `plr_18` |
| `plsh` | `plsh_18` |
| `plxslt` | `plxslt_18` |
| `pointcloud` | `pointcloud_18` |
| `pointcloud_postgis` | `pointcloud_18` |
| `postgis` | `postgis37_18` |
| `postgis_raster` | `postgis37_18` |
| `postgis_sfcgal` | `postgis37_18` |
| `postgis_tiger_geocoder` | `postgis_tiger_geocoder_18` |
| `postgis_topology` | `postgis37_18` |
| `postgres_fdw` | `postgresql18-contrib` |
| `powa` | `powa-archivist_18` |
| `prefix` | `prefix_18` |
| `prioritize` | `pg_prioritize_18` |
| `q3c` | `q3c_18` |
| `rdf_fdw` | `rdf_fdw_18` |
| `refint` | `postgresql18-contrib` |
| `repmgr` | `repmgr_18` |
| `roaringbitmap` | `pg_roaringbitmap_18` |
| `seg` | `postgresql18-contrib` |
| `semver` | `semver_18` |
| `sequential_uuids` | `sequential_uuids_18` |
| `set_user` | `set_user_18` |
| `sslinfo` | `postgresql18-contrib` |
| `sslutils` | `sslutils_18` |
| `system_stats` | `system_stats_18` |
| `table_version` | `table_version_18` |
| `tablefunc` | `postgresql18-contrib` |
| `tcn` | `postgresql18-contrib` |
| `tdigest` | `tdigest_18` |
| `tds_fdw` | `tds_fdw_18` |
| `timescaledb` | `timescaledb_18` |
| `timestamp9` | `timestamp9_18` |
| `toastinfo` | `toastinfo_18` |
| `topn` | `topn_18` |
| `tsm_system_rows` | `postgresql18-contrib` |
| `tsm_system_time` | `postgresql18-contrib` |
| `uint` | `pguint_18` |
| `unaccent` | `postgresql18-contrib` |
| `unit` | `postgresql-unit_18` |
| `uri` | `pguri_18` |
| `uuid-ossp` | `postgresql18-contrib` |
| `vector` | `pgvector_18` |
| `vectorscale` | `pgvectorscale_18` |
| `xml2` | `postgresql18-contrib` |

## Inspect the image

```sh
docker run --rm pg-deps cat /var/lib/pg-deps/failed.txt
docker run --rm pg-deps cat /var/lib/pg-deps/install.log
docker run --rm pg-deps bash -c 'for f in /usr/pgsql-18/share/extension/*.control; do basename "$f" .control; done'
```
