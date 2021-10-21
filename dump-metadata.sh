#!/bin/bash

if [[ -z "$1" ]]
then
    echo "Must supply data location."
    exit 1;
fi

DATA=$1
METADATA=$DATA/metadata

echo "hash,scenario"

# Note: if the scenario has commas in it, this will mess up the CSV (but this will be visible when trying to postprocess, and just need to special case it here
for dirname in $METADATA/*
do
    echo `echo $dirname | xargs basename`,`cat $dirname/scenario.txt`
done
