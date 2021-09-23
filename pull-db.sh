#!/bin/bash
  
set +x

source common.sh
source .env

DESTINATION=./tmp/

# delete old data dumps
removeDirs() {
        rm -rf ${DESTINATION}
}

# create destination dirs
createDirs() {
        mkdir -p ${DESTINATION}
        mkdir -p ${LOGS}
}

# down the database from the blobs
downloadDatabases() {
        for item in ${SITES[@]}
        do
                url=${DOWNLOAD_URL1}/${item}/sequences/${item}_${DOWNLOAD_URL2}
                echo "Downloading backup for ${item}: ${url}"
                azcopy copy "${url}" "${DESTINATION}" --overwrite=prompt --check-md5 FailIfDifferent --from-to=BlobLocal --blob-type Detect --recursive;
        done
        }

# extract the databases
extractDb() {
        for item in ${SITES[@]}
        do
                target=${DESTINATION}/openmrs-${item}/openmrs.sql
                echo "Extracting to ${target}"
                7za e -p"${PASS}" ${DESTINATION}/${item}_backup_${DATE}.sql.7z -o${DESTINATION}/openmrs-${item}
                mv ${DESTINATION}/openmrs-${item}/y ${target}
        done
}


removeDirs
createDirs
downloadDatabases
echo Waiting 10 seconds...
sleep 10
extractDb
