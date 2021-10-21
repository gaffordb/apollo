#!/bin/bash

BLUE='\033[0;94m'
NC='\033[0m' # No Color

mkdir -p data/coverage

RUNDATA=data/coverage
COV_FILE=data/log/planning.INFO
COV_HASH=`md5sum $COV_FILE | cut -d' ' -f 1`
echo "RUN_HASH: $COV_HASH"

./fix-lcov.sh &> /dev/null
COV_INFO=coverage$1-$COV_HASH
COV_INFO_FILE=$COV_INFO.info

python -m fastcov -q -b --lcov -d ./cyber/bazel-out/k8-opt/bin/modules -o $COV_INFO_FILE

python -m fastcov -q --lcov -C $COV_INFO_FILE --include "modules/planning" -o planning-$COV_INFO_FILE

genhtml planning-$COV_INFO_FILE -q --ignore-errors=source -o planning-$COV_INFO &>/dev/null
genhtml $COV_INFO_FILE -q --ignore-errors=source -o $COV_INFO &>/dev/null

mv $COV_INFO_FILE $RUNDATA/
mv planning-$COV_INFO_FILE $RUNDATA/

mv $COV_INFO $RUNDATA/
mv planning-$COV_INFO $RUNDATA/

echo -e "${BLUE}Generated coverage report at ${RUNDATA}/planning-${COV_INFO} ${NC}"

