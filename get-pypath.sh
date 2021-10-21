#!/bin/bash

# Running python files through bazel is (1) annoying and (2) breaks other scripts (e.g., bootstrap_lgsvl && bridge.sh)
# This just 

PYPATH=`find $PWD -path $PWD/.cache/bazel/*/execroot/apollo/bazel-out/k8-opt/bin/modules/tools/record_analyzer/main.runfiles/apollo`

echo "PYTHONPATH=$PYPATH" > pypath.src



