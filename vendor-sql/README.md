# Vendored SQL files

These files are manually copied snapshots, not managed by a Maven dependency. They will not
automatically pick up upstream changes — if the source files change, these need to be
re-copied by hand.

## dataexports/

Copied from `openmrs-config-pihemr`'s `configuration/reports/reportdescriptors/dataexports/sql/`
(https://github.com/PIH/openmrs-config-pihemr), not from `ces-etl`'s own `openmrs-config-ces`/`ces-emr`
distro despite the similar naming — these particular report SQL files are part of the shared PIH EMR
report set, not CES-specific ones.

- `users.sql`
- `user_roles.sql`
- `user_logins.sql`
- `summary_db_restore.sql`

## liquibase/

Copied from `openmrs-config-ces`'s (now `ces-emr`'s) `content/configuration/pih/liquibase/sql/`
(https://github.com/PIH/openmrs-config-ces) — these are genuinely CES-specific.

- `clean_up_inconsistent_mappings.sql`
- `migrate_adjustment_disorder_diagnosis.sql`

Vendored 2026-07-24, when `ces-etl` dropped its Maven dependency on `org.pih.openmrs:openmrs-config-ces`
(that repo removed the build mechanism that produced the zip artifact this depended on).
