#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}

NAME=$(basename ${OUTPUT_FILE} .zip)

mkdir ${NAME}

for DEP in ${DEPS}; do
    echo ${DEP}

    DEP_NAME=$(basename ${DEP})

    # copy configure.log file if found in dep, otherwise copy the dep
    LOG_FILE=$(find ${DEP} -name "configure.log" -type f)
    if [ ! -z "${LOG_FILE}" ]; then
        cp ${LOG_FILE} ${NAME}/${DEP_NAME}.log
    elif [ -f ${DEP} ]; then
        cp ${DEP} ${NAME}/
    fi
done

zip -r ${OUTPUT_FILE} ${NAME}
