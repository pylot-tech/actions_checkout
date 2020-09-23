#!/bin/bash

IFS=';' read -ra ARRA <<< "$TALOS_DEPS"

for i in "${ARRA[@]}"; do
    IFS=':' read -ra ARRB <<< "$i"
    if [ -z "${ARRB[1]}" ]
    then
        git clone --depth 1 https://${HTTPS_PAT}@github.com/pylot-tech/${ARRB[0]}.git ./src/${ARRB[0]}    
    else
        git clone --depth 1 -b ${ARRB[1]} https://${HTTPS_PAT}@github.com/pylot-tech/${ARRB[0]}.git ./src/${ARRB[0]} 
    fi    
done
