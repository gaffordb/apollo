#!/bin/bash

shopt -s globstar

# Create symlinks of the gcno files to the same directory as the gcda files
# for processing by gcov (this is how they need it to be)
find $PWD -type f -wholename '**/.cache/**/bazel-out/k8-opt/**/*.pic.gcno' | while read FILE ; do
    #echo $FILE
    TAR=`echo $FILE | sed -e 's/\.cache\/bazel.*\/bazel-out/cyber\/bazel-out/g'`
    ln -sf $FILE $TAR
done
