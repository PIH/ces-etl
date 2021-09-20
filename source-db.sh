#!/bin/bash
  
source .env
DATABASE="openmrs.sql"

TIME=`date +%Y%m%d-%H%M%S`

function db_name {
        return "openmrs_$(sed 's/-/_/g' <<< $1)"
}


dropDB() {
        for site in ${SITES[@]}
        do
                db=$(db_name ${site})
                echo "Dropping of ${db} started at ${TIME}"  >> ${LOGS}/dbdrop_${DATE}.log
                mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} -e "drop database if exists ${db};"
                echo "Dropping of ${db} ended at ${TIME}"  >> ${LOGS}/dbdrop_${DATE}.log
        done
}

createDB() {
        for site in ${SITES[@]}
        do
                db=$(db_name ${site})
                echo "Creation of ${db} started at ${TIME}"  >> ${LOGS}/dbcreate_${DATE}.log
                mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} -e "create database ${db} default char set utf8;"
                echo "Creation of ${db} ended at ${TIME}"  >> ${LOGS}/dbcreate_${DATE}.log
        done
}

sourceDB() {

        for site in ${SITE[@]}
        do
                db=$(db_name ${site})
                echo "Import of ${db} started at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log
                mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} ${db} < ${DESTINATION}/openmrs-${site}/${DATABASE}
                echo "Import of ${db} ended at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log
        done
}


dropDB
sleep 10
createDB
sleep 10
sourceDB
