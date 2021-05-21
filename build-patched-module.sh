#!/bin/bash

if [ -z "$1" ]
then
    echo "please supply patch file"
    exit
fi

PATCH_FILE=$1

# Get the base filename (must be .cc file)
BASE_FNAME=`echo $(basename $PATCH_FILE) | cut -d'.' -f 1`
FULL_FNAME=$BASE_FNAME".cc"
# Note: file must be unique...
FULL_PATH=`find modules -name $FULL_FNAME`
MODULE_NAME=`echo $FULL_PATH | cut -d'/' -f 2`

echo $BASE_FNAME
echo $FULL_FNAME
echo $FULL_PATH
echo $MODULE_NAME

if [ -z "$FULL_PATH" ]
then
    echo "Failed to find file to patch"
    exit
fi

if [ -z "$MODULE_NAME" ]
then
    echo "Failed to module name"
    exit
fi


echo "Patching $FULL_PATH in module: $MODULE_NAME..."
if [ "$2" != "undo" ]
then
    # Patch file
    patch $FULL_PATH $PATCH_FILE
    
    # Build patched module
    #bazel build modules/$MODULE_NAME:all (this messes up launch stuff?)
    ./apollo.sh build_opt_gpu
    
    PATCH_HASH=`md5sum $PATCH_FILE | cut -d' ' -f 1`
    mkdir -p patched-bin/$PATCH_HASH
    
    # Copy patched module output to other dir
    cp -rf bazel-bin/modules/$MODULE_NAME patched-bin/$PATCH_HASH
else
    # Unpatch file
    patch -R $FULL_PATH $PATCH_FILE

    # Rebuild original module
    #bazel build modules/$MODULE_NAME:all
    ./apollo.sh build_opt_gpu
fi


