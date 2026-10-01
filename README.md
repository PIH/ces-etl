# ces-etl

PETL and other data pipeline scripts for CES / PIH Mexico

This lives at `/opt/ces-etl` on ces-laguna.pih-emr.org. `pull-db.sh` and `source-db.sh` run on the root crontab.

To "deploy," do `git pull` in that directory.

## Cron Jobs

Cron jobs are monitored in the [Mexico EMR](https://hcping.pih-emr.org/projects/6f600f51-f183-440e-8085-b7aef1813c6d/checks/) job of the PIH EMR Healthchecks service.

## PETL

The PETL jobs and datasource configurations are in this directory.
The PETL installation, located in the usual directory at
`/home/petl/bin/`, refers to `/opt/ces-etl/petl` for these configurations.

The reason these are in this repository and not in
[config-ces](https://github.com/PIH/openmrs-config-ces) is
because at the time of this writing (Oct 2021), CES ETL is colocated
with the CES Laguna EMR  (a production system), which means that deploying
`config-ces` causes EMR downtime. The config files in this directory
can be "deployed" independently of `config-ces` and the EMR.

# Docker image

`partnersinhealth/ces-etl` layers this project's `datasources/`, `jobs/` and `application-docker.yml`
(as its `application.yml`) on the [PETL](https://github.com/PIH/petl) base image,
`partnersinhealth/petl`. CI builds and pushes it (`Dockerfile`, build context `target/docker/`,
populated by `mvn package`) on every push to `master` and on every release, tagged `latest` and the
version. To build it locally: `./build-runtime-docker-image.sh`, which layers on a locally built
`partnersinhealth/petl:local`. When a new PETL image is published, petl's
workflow triggers this build with that image's digest, and the image is built on exactly it.

It runs as [openmrs-contrib-distro-tools](https://github.com/PIH/openmrs-contrib-distro-tools)'
`petl` service (see its `docs/services.md`), e.g. for ces-ci:

    PETL_IMAGE_NAME=partnersinhealth/ces-etl
    PETL_FULL_REFRESH_JOBS="create-partitions.yml refresh-cesci-data.yml"
    PETL_SQLSERVER_DATABASE=openmrs_ces_ci

`application-docker.yml` maps the `cesci` OpenMRS datasource and the `warehouse` SQL Server
datasource onto distro-tools' `PETL_MYSQL_*` and `PETL_SQLSERVER_*` variables. The other sites'
datasources aren't set; set one by its Spring environment-variable name where it's needed (e.g.
`DATASOURCES_OPENMRS_CAPITAN_HOST`).
