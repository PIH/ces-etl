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
