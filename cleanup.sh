#!/bin/bash

rm ./data/core/core*
rm ./nohup.out

if [ "$1" = "all" ]; then
  echo "rm ./data/log/*"
fi
