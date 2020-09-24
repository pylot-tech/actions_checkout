#!/bin/bash

if [ "${EVENT_NAME}" = "push" ] || [ "${EVENT_NAME}" = "schedule" ]
then
    IFS='/' read -ra ARRD <<< "${REF}"
    # this fetches the last element of the array.
    BRANCH=${ARRD[${#ARRD[@]}-1]}
elif [ "${EVENT_NAME}" = "pull_request" ]
then
    BRANCH=${HEAD_REF}
else
    exit 0
fi

# Clone the main repo (that is subject of the build)
IFS='/' read -ra ARRC <<< "${REPOSITORY}"
git clone --depth 1 -b ${BRANCH} https://${HTTPS_PAT}@github.com/${REPOSITORY} ./src/${ARRC[1]}

IFS=';' read -ra ARRA <<< "${TALOS_DEPS}"

for i in "${ARRA[@]}"; do
    IFS=':' read -ra ARRB <<< "$i"
    if [ -z "${ARRB[1]}" ]
    then
        git clone --depth 1 https://${HTTPS_PAT}@github.com/pylot-tech/${ARRB[0]}.git ./src/${ARRB[0]}    
    else
        git clone --depth 1 -b ${ARRB[1]} https://${HTTPS_PAT}@github.com/pylot-tech/${ARRB[0]}.git ./src/${ARRB[0]} 
    fi    
done
