#!/bin/bash

set +x

source /home/azcopy/.env

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

		for item in ${SITE[@]}
                                        do
						azcopy copy "${DOWNLOAD_URL1}/${item}/sequences/${item}_${DOWNLOAD_URL2}" "${DESTINATION}" --overwrite=prompt --check-md5 FailIfDifferent --from-to=BlobLocal --blob-type Detect --recursive;

					done
		}

# extract the databases
extractDb() {
	                for item in ${SITE[@]}
				do
					7za e -p"${PASS}" ${DESTINATION}/${item}_backup_${DATE}.sql.7z -o${DESTINATION}/openmrs-${item}
					mv ${DESTINATION}/openmrs-${item}/y ${DESTINATION}/openmrs-${item}/openmrs.sql
				done
}


removeDirs
createDirs
downloadDatabases
sleep 10
extractDb
