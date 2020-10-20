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

# github sometimes times out on the initial clone attempt.
# let's just try again a few times in this case.
n=0
until [ "$n" -ge 5 ]
do
   git clone --depth 1 -b ${BRANCH} https://${HTTPS_PAT}@github.com/${REPOSITORY} ./src/${ARRC[1]} && break
   n=$((n+1)) 
   sleep 5
done



IFS=';' read -ra ARRA <<< "${TALOS_DEPS}"

for i in "${ARRA[@]}"; do
    IFS=':' read -ra ARRB <<< "$i"
    if [ -z "${ARRB[1]}" ]
    then
        n=0
        until [ "$n" -ge 5 ]
        do
            git clone --depth 1 https://${HTTPS_PAT}@github.com/pylot-tech/${ARRB[0]}.git ./src/${ARRB[0]} && break
            n=$((n+1)) 
            sleep 5
        done
        
    else
        n=0
        until [ "$n" -ge 5 ]
        do
            git clone --depth 1 -b ${ARRB[1]} https://${HTTPS_PAT}@github.com/pylot-tech/${ARRB[0]}.git ./src/${ARRB[0]} && break
            n=$((n+1)) 
            sleep 5
        done 
    fi    
done

cd ./src
echo "" > versions.log
for D in *; do
    if [ -d "${D}" ]; then        
        cd ${D}
        NAME=$(basename `git rev-parse --show-toplevel`)
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
        REF=$(git rev-parse HEAD)
        printf "%20s; %30s; %41s" $NAME $BRANCH $REF >> ../versions.log
        echo "" >> ../versions.log
        # git fetch        
        cd ..
    fi
done
cat versions.log
