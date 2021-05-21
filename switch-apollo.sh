#!/bin/bash

if [ -z "$1" ]
then
    rm -rf ./bazel-bin/modules/
    # Could do this more efficiently, but whatever...
    cp -r $PWD/patched-bin/original/modules $PWD/bazel-bin/modules
    echo "Switched back to original."
    echo "original" > MODULE-VERSION.txt
    exit
fi

MODULE=`basename patched-bin/$1/*`

mv ./bazel-bin/modules/$MODULE ./bazel-bin/modules/.$MODULE
cp -r $PWD/patched-bin/$1/$MODULE $PWD/bazel-bin/modules/$MODULE

echo "Switched module:$MODULE to $1"
echo "$MODULE-VERSION:$1" > MODULE-VERSION.txt
