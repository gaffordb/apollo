#!/bin/bash

BLUE='\033[0;94m'
NC='\033[0m' # No Color

RUNDATA=data/coverage
COV_FILE=data/log/planning.INFO
COV_HASH=`md5sum $COV_FILE | cut -d' ' -f 1`

./fix-lcov.sh
COV_INFO=coverage$1-$COV_HASH
COV_INFO_FILE=$COV_INFO.info
#lcov --no-external --capture --initial --directory ./cyber/bazel-out/k8-fastbuild/bin/modules --output-file $COV_INFO_FILE.base

lcov --directory ./cyber/bazel-out/k8-opt/bin/modules --capture --output-file $COV_INFO_FILE

#lcov --add-tracefile $COV_INFO_FILE.base --add-tracefile $COV_INFO_FILE.total --output-file $COV_INFO_FILE
lcov --extract $COV_INFO_FILE "*planning*" -o planning-$COV_INFO_FILE

genhtml planning-$COV_INFO_FILE --ignore-errors source -o planning-$COV_INFO
genhtml $COV_INFO_FILE --ignore-errors source -o $COV_INFO

mv $COV_INFO_FILE $RUNDATA
mv planning-$COV_INFO_FILE $RUNDATA
mv $COV_INFO $RUNDATA
mv planning-$COV_INFO $RUNDATA

echo -e "${BLUE}Generated coverage report at ${RUNDATA}/planning-${COV_INFO} ${NC}"

