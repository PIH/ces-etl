#!/bin/bash
  
source common.sh
source .env

DATABASE="openmrs.sql"

function db_name {
        echo "openmrs_$(sed 's/-/_/g' <<< $1)"
}


dropDB() {
        for site in ${SITES[@]}
        do
                db=$(db_name ${site})
                echo "Dropping of ${db} started at $(date)"  | tee -a ${LOGS}/dbdrop_${DATE}.log
                mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} -e "drop database if exists ${db};"
                echo "Dropping of ${db} ended at $(date)"  | tee -a ${LOGS}/dbdrop_${DATE}.log
        done
}

createDB() {
        for site in ${SITES[@]}
        do
                db=$(db_name ${site})
                echo "Creation of ${db} started at $(date)"  | tee -a ${LOGS}/dbcreate_${DATE}.log
                mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} -e "create database ${db} default char set utf8;"
                echo "Creation of ${db} ended at $(date)"  | tee -a ${LOGS}/dbcreate_${DATE}.log
        done
}

sourceDB() {

        for site in ${SITES[@]}
        do  
                db=$(db_name ${site})
                echo "Import of ${db} started at $(date)"  | tee -a ${LOGS}/dbrestore_${DATE}.log
                mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} ${db} < ${TMP}/openmrs-${site}/${DATABASE} && \
            curl -fsS -m 10 --retry 5 -o /dev/null ${HEALTHCHECK_FOR_SITE["$site"]}
                echo "Import of ${db} ended at $(date)"  | tee -a ${LOGS}/dbrestore_${DATE}.log
        done    
}


dropDB
sleep 10
createDB
sleep 10
sourceDB
