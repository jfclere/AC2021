#!/bin/sh
#
# Runs tests across all concurrency levels.
#
SCRIPT_DIR=`dirname "${0}"`

REPORT_BASE_DIR=${1:-.}
TIME_LIMIT=${2:-300}
SLEEP_TIME=${3:-5}
HOST=${4:-localhost}
HTTPDPORT=${5:-80}
HTTPDSPORT=${6:-443}

LENGTH_ESTIMATE=`expr 14 '*' 6 '*' '(' "${TIME_LIMIT}" + "${SLEEP_TIME}" ')' / 60`
echo "Expect this test to last ${LENGTH_ESTIMATE} minutes."

#for c in 1 40 80 160 250 ; do
#for c in 1 40 80 ; do
#for c in 1 40 ; do
#for c in 80 ; do
for c in 240 ; do
 echo Making directory "${REPORT_BASE_DIR}/c${c}"
 echo Testing "${HOST}" "${HTTPDPORT}"
 mkdir -p "${REPORT_BASE_DIR}/c${c}"
 "${SCRIPT_DIR}/runurltests.sh" "${TIME_LIMIT}" ${c} "${REPORT_BASE_DIR}/c${c}" "${SLEEP_TIME}" "${HOST}" "${HTTPDPORT}" "${HTTPDSPORT}"
done

