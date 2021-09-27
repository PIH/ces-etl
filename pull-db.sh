#!/bin/bash
#
# Requires the following variables in `.env`:
#  - BACKUP_URL_TEMPLATE (should have a substring `${SITE}` (without the backticks))

set +x

source common.sh
source .env

# delete old data dumps
removeDirs() {
        rm -rf ${TMP}
}

# create destination dirs
createDirs() {
        mkdir -p ${TMP}
        mkdir -p ${LOGS}
}

# down the database from the blobs
downloadDatabases() {
        for SITE in ${SITES[@]}
        do  
                URL=$(echo ${BACKUP_URL_TEMPLATE} | sed 's/${SITE}/'${SITE})
                echo "Downloading backup for ${SITE}: ${URL}"
                azcopy copy "${URL}" "${TMP}" --overwrite=prompt --check-md5 FailIfDifferent --from-to=BlobLocal --blob-type Detect --recursive;
        done
        }   

# extract the databases
extractDb() {
        for SITE in ${SITES[@]}
        do  
                TARGET=${TMP}/openmrs-${SITE}/openmrs.sql
                echo "Extracting to ${TARGET}"
                7za e -p"${PASS}" ${TMP}/${item}_backup_${DATE}.sql.7z -o${TMP}/openmrs-${SITE}
                mv ${TMP}/openmrs-${SITE}/y ${TARGET}
        done
}


removeDirs
createDirs
downloadDatabases
echo Waiting 10 seconds...
sleep 10
extractDb
