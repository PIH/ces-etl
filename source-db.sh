#!/bin/bash
#
# Requires the following variables in `.env`:
#   - DBUSER
#   - DBPASS

source common.sh
source .env

DATABASE="openmrs.sql"

for site in ${SITES[@]}
do
    backupFile=${TMP}/openmrs-${site}/${DATABASE}
    if [[ -f ${backupFile} ]]; then
        db=openmrs_$(sed 's/-/_/g' <<< ${site})
        echo "Dropping ${db} at $(date)"  | tee -a ${LOGS}/dbdrop_${DATE}.log
        mysql -h 127.0.0.1 -u${DBUSER} -p${DBPASS} -e "drop database if exists ${db};"
        sleep 10
        echo "Creating ${db} at $(date)"  | tee -a ${LOGS}/dbcreate_${DATE}.log
        mysql -h 127.0.0.1 -u${DBUSER} -p${DBPASS} -e "create database ${db} default char set utf8;"
        sleep 10
        echo "Import of ${db} started at $(date)"  | tee -a ${LOGS}/dbrestore_${DATE}.log
        mysql -h 127.0.0.1 -u${DBUSER} -p${DBPASS} ${db} < ${backupFile} && \
            curl -fsS -m 10 --retry 5 -o /dev/null ${HEALTHCHECK_FOR_SITE["$site"]}
        echo "Import of ${db} ended at $(date)"  | tee -a ${LOGS}/dbrestore_${DATE}.log
    else
        echo "WARNING: Database backup file does not exist for site ${site} at ${backupFile}. Skipping."
    fi  
done
