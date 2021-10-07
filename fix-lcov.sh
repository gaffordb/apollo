#!/bin/bash

shopt -s globstar

find $PWD -type f -wholename '**/.cache/**/bazel-out/k8-opt/**/*.pic.gcno' | while read FILE ; do
    echo $FILE
    TAR=`echo $FILE | sed -e 's/\.cache\/bazel.*\/bazel-out/cyber\/bazel-out/g'`
    ln -sf $FILE $TAR
done

#TAR=`echo $S2 | sed -e 's/\.cache\/bazel.*\/bazel-out/cyber\/bazel-out/g'`
#echo $TAR
#echo $S1
#echo $S2

#echo ./.cache | sed -e 's/\.cache/cyber/g'
#ln -s $S2 $TAR
