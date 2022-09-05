#!/bin/bash
#
# Runs tests on all base URLs for a particular concurrency level.
#

# Enough requests to fill 10 minutes?
#REQUESTS=10000000
REQUESTS=100000

TIME_LIMIT=${1:-30}
CONCURRENCY=${2:-40}
REPORT_DIR=${3:-.}
SLEEP_TIME=${4:-5}
HOST=${5:-localhost}
HTTPDPORT=${6:-8089}
HTTPDSPORT=${7:-8099}
USE_H2=${8:true}
HTTPD_ONLY=false
SKIP_HTTP_TESTS=false
SKIP_HTTPS_TESTS=false
REPORT_FILE="results_httpd.txt"

SCRIPT_DIR=`dirname "${0}"`

export REPORT_DIR
export REPORT_FILE


function quit {
  echo
  exit
}

trap "quit" INT TERM EXIT

# Proxy AJP SSL tests.
REPORT_FILE=results_proxy_ajp
echo "Pretest warm up..."
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/tcaj/ ${USE_H2}
#"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/tcaj/ ${USE_H2} >/dev/null
echo "Waiting ${SLEEP_TIME}..."
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/tcaj/ ${USE_H2} | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Proxy HTTP
REPORT_FILE=results_proxy_http
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/tchp/ ${USE_H2} >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/tchp/ ${USE_H2} | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Mod_jk
REPORT_FILE=results_mod_jk
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/jkaj/ ${USE_H2} >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/jkaj/ ${USE_H2} | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

quit
