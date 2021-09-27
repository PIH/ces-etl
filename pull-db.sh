#!/bin/bash
  
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
        for item in ${SITES[@]}
        do  
                url=${DOWNLOAD_URL1}/${item}/sequences/${item}_${DOWNLOAD_URL2}
                echo "Downloading backup for ${item}: ${url}"
                azcopy copy "${url}" "${TMP}" --overwrite=prompt --check-md5 FailIfDifferent --from-to=BlobLocal --blob-type Detect --recursive;
        done
        }   

# extract the databases
extractDb() {
        for item in ${SITES[@]}
        do  
                target=${TMP}/openmrs-${item}/openmrs.sql
                echo "Extracting to ${target}"
                7za e -p"${PASS}" ${TMP}/${item}_backup_${DATE}.sql.7z -o${TMP}/openmrs-${item}
                mv ${TMP}/openmrs-${item}/y ${target}
        done
}


removeDirs
createDirs
downloadDatabases
echo Waiting 10 seconds...
sleep 10
extractDb
