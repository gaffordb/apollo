#!/bin/bash

BLUE='\033[0;94m'
NC='\033[0m' # No Color

./cleanup.sh
lcov --directory . --zerocounters

bootstrap_lgsvl.sh start

echo -e "${BLUE}Reset apollo processes, cleared counters. Running bridge...${NC}"
bridge.sh

pkill -SIGUSR2 mainboard
