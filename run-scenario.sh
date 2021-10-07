#!/bin/bash
# Goal:
# - Run some set of scenarios and save the coverage data and logs.
# 
# Process:
# - Start simulator if not already started
#   - (this is hard to automate given 2021.02 version)
# - Record run
# - Gather coverage information

set -o history -o histexpand

BLUE='\033[0;94m'
NC='\033[0m' # No Color

AVAILABLE_COMMANDS="--scenario --accumulate --help -h"

function _usage() {
    local commands="$(echo ${AVAILABLE_COMMANDS} | xargs)"
    echo "./run-scenario.sh ${commands}"
}
function _check_command() {
    local name="${BASH_SOURCE[0]}"
    local commands="$(echo ${AVAILABLE_COMMANDS} | xargs)"

    echo "Invalid argument: ${key}."
    echo "Usage:"
    _usage
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -a|--accumulate)
      ACCUMULATE=1
      shift # past argument
      ;;
    -s|--scenario)
      SCENARIO="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
	HELP=1
	_usage
	exit
      shift # past argument
      ;;
    *)    # unknown option
	_check_command "${key}"
	exit
      shift
      ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

# Check that the simulator is ready
if ! pgrep simulator ;
then
    echo "Please start the simulator and prepare for API."
    exit
fi

CONTAINER_ID=`docker ps -aqf "name=apollo_dev_bgafford"`

# Check that Apollo is ready
if [[ -z "$CONTAINER_ID" ]] ;
then
    echo "Apollo not ready. Starting apollo docker container..."
    ./docker/scripts/dev_start.sh
fi

trap manage_cleanup INT

function manage_cleanup() {
    echo "Trying to kill spawned processes..."
    docker exec -u $USER -it $CONTAINER_ID /apollo/scripts/bootstrap_lgsvl.sh stop
    pkill -f /apollo/scripts/bridge.sh
    pkill -f contrib/cyber_bridge/cyber_bridge
    pkill -f cyber_recorder
    pkill -SIGUSR2 mainboard
    exit
}

if ! [[ -z "$(find . -name "*gcda")" ]]  ;
then
    echo "[WARNING] There are existing coverage data files. Coverage from these files will be included in the data produced from this script."
    echo "To remove old coverage data files, execute the following command:"
    echo "lcov --directory . --zerocounters"
fi

echo -e "${BLUE}Starting Apollo bridge...${NC}"

# Prepare apollo
docker exec -u $USER $CONTAINER_ID /apollo/scripts/bootstrap_lgsvl.sh
docker exec -u $USER $CONTAINER_ID /apollo/scripts/bridge.sh &
docker exec -u $USER $CONTAINER_ID /apollo/bazel-bin/cyber/tools/cyber_recorder/cyber_recorder record -a

sleep 5

echo -e "${BLUE}Running scenario...${NC}"

# Run scenic scenario
#scenic ~/PythonAPI/Scenic/Scenic/examples/lgsvl/scenic-cut-in-new.scenic --time=60 --simulate --count=1 -b
eval $SCENARIO

#while read F  ; do
#    bash $F
#    pkill -SIGUSR2 mainboard
#    sleep 2
#done <./scenarios.txt


echo -e "${BLUE}Stopping processes...${NC}"
# Stop processes, clean up
docker exec -u $USER -it $CONTAINER_ID /apollo/scripts/bootstrap_lgsvl.sh stop
pkill -f /apollo/scripts/bridge.sh
pkill -f contrib/cyber_bridge/cyber_bridge
pkill -f cyber_recorder

# Wait for mainboard processes to spit out coverage data (takes a sec)
# Mainboard processes correspond to modules
sleep 2

echo -e "${BLUE}Gathering coverage data...${NC}"
# Record run
docker exec -u $USER /apollo/get-coverage.sh -script

RUN_FILE=data/log/planning.INFO
RUN_HASH=`md5sum $COV_FILE | cut -d' ' -f 1`

mkdir -p data/records/$RUN_HASH

mv *.record* data/records/$RUN_HASH 

echo -e "${BLUE}Cleaning up...${NC}"
# Clean up
./cleanup.sh
#lcov --directory . --zerocounters



