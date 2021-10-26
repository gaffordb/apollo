#!/bin/bash

BLUE='\033[0;94m'
NC='\033[0m' # No Color

RUNDATA=data/coverage
COV_FILE=data/log/planning.INFO
COV_HASH=`md5sum $COV_FILE | cut -d' ' -f 1`
COV_PATH=$RUNDATA/$COV_HASH

mkdir -p $COV_PATH

echo "RUN_HASH: $COV_HASH"

./fix-lcov.sh &> /dev/null
COV_INFO=$COV_HASH-coverage
COV_INFO_FILE=$COV_INFO.info
PLANNING_INFO=$COV_INFO-planning.info

python -m fastcov -q -b --lcov -d ./cyber/bazel-out/k8-opt/bin/modules -o $COV_INFO_FILE

python -m fastcov -q --lcov -C $COV_INFO_FILE --include "modules/planning" -o $PLANNING_INFO

genhtml $PLANNING_INFO -q --ignore-errors=source -o $COV_INFO-planning &>/dev/null
genhtml $COV_INFO_FILE -q --ignore-errors=source -o $COV_INFO &>/dev/null

mv $COV_INFO_FILE $COV_PATH/
mv $PLANNING_INFO $COV_PATH/

mv $COV_INFO $COV_PATH/
mv $COV_INFO-planning $COV_PATH/

echo -e "${BLUE}Generated coverage report at ${COV_PATH} ${NC}"

