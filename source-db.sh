#!/bin/bash

source /home/azcopy/.env
DATABASE="openmrs.sql"

DBS=(
ces_reforma
ces_soledad
ces_capitain
ces_plan
ces_salvador
)

TIME=`date +%Y%m%d-%H%M%S`

dropDB() {
                for db in ${DBS[@]}
                        do
                                echo "Dropping of ${db} started at ${TIME}"  >> ${LOGS}/dbdrop_${DATE}.log
                                mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} -e "drop database if exists openmrs_${db};"
                                echo "Dropping of ${db} ended at ${TIME}"  >> ${LOGS}/dbdrop_${DATE}.log
                        done
}

createDB() {
		for db in ${DBS[@]}
			do
				echo "Import of ${db} started at ${TIME}"  >> ${LOGS}/dbcreate_${DATE}.log
				mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} -e "create database openmrs_${db} default char set utf8;"
				echo "Import of ${db} ended at ${TIME}"  >> ${LOGS}/dbcreate_${DATE}.log
			done
}

sourceDB() {
	
		#echo "Import of openmrs-ces-plan started at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log
		#mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} openmrs_ces_capitain < ${DESTINATION}/openmrs-ces-capitain/${DATABASE}
		#echo "Import of openmrs-ces-plan ended at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log		

		echo "Import of openmrs-ces-plan started at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log
		mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} openmrs_ces_plan < ${DESTINATION}/openmrs-ces-plan/${DATABASE}
		echo "Import of openmrs-ces-plan ended at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log
		
		echo "Import of openmrs-ces-reforma started at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log
		mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} openmrs_ces_reforma < ${DESTINATION}/openmrs-ces-reforma/${DATABASE}
                echo "Import of openmrs-ces-reforma ended at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log

		echo "Import of openmrs-ces-salvado started at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log
		mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} openmrs_ces_salvador < ${DESTINATION}/openmrs-ces-salvador/${DATABASE}
                echo "Import of openmrs-ces-salvado ended at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log

		echo "Import of openmrs-ces-soledad started at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log
		mysql -h 127.0.0.1 -u${ROOT} -p${ROOTPWD} openmrs_ces_soledad < ${DESTINATION}/openmrs-ces-soledad/${DATABASE}
                echo "Import of openmrs-ces-soledad ended at ${TIME}"  >> ${LOGS}/dbrestore_${DATE}.log


}


dropDB
sleep 10
createDB
sleep 10
sourceDB
