#!/bin/bash

CONTAINER_ID=`docker ps -aqf "name=apollo_dev"`

ITERATIONS=$1

if [[ -z "$1" ]]
then  
    ITERATIONS=1
fi

echo "Gathering data for $ITERATIONS iterations over the scenarios in scenarios.txt..."

# Get the pypath if it doesn't already exist
if [[ ! -e "pypath.src" ]]
then
    echo "pypath not found. Generating pypath..."
    docker exec -u $USER $CONTAINER_ID /apollo/get-pypath.sh
fi

function handle_interrupt() {
    # This lets us out of the failure-rerun loop...
    DONE=1
    exit;
}

trap handle_interrupt INT

function run_success() {
    # Returns 0 if the run succeeded, otherwise nonzero
    local RUN_FILE=data/log/planning.INFO
    local RUN_HASH=`md5sum $RUN_FILE | cut -d' ' -f 1`
    local RECORD_FILE=`find ./data/records/$RUN_HASH -name "*.record.00000" | cut -f 1 -d$'\n'`
    echo "RUN HASH: $RUN_HASH"
    if [[ ! -z "$RECORD_FILE" ]]
    then	
	docker exec --env-file pypath.src -u $USER $CONTAINER_ID python3 modules/tools/record_analyzer/main.py -f $RECORD_FILE > /tmp/out$RUN_HASH.txt
	local RET=0

	# Test 1: Did the record gather any data?
	grep "Average" /tmp/out$RUN_HASH.txt &>/dev/null
	RET=`expr $RET + $?`

	# Test 2: Did the planning module output any good data?
	local TEST2=`grep -c -E "(UNKNOWN\s=\s[0-9]+\(100.00%\))" /tmp/out$RUN_HASH.txt`
	RET=`expr $RET + $TEST2`
	
	rm /tmp/out$RUN_HASH.txt
	echo "Record file found @ $RECORD_FILE. Output: $RET"
	return $RET
    else
	echo "No record file found."
	return 1
    fi
}

docker exec -u $USER $CONTAINER_ID lcov --directory /apollo/ --zerocounters

SUCCESSFUL_ITERATIONS=0

while read F  ; do
    if [[ ! -z "$F" ]]
    then
	echo "Gathering data for $F"
	for i in `seq 1 $ITERATIONS` 
	do
	    FAIL_COUNT=0
	    
	    echo "Running iteration: $i of $F"
	    ./run-scenario.sh --scenario "$F --seed=$i"
	    docker exec -u $USER $CONTAINER_ID lcov --directory /apollo/ --zerocounters
	    run_success
	    _res=$?

	    while [[ $_res != 0 ]] && [[ -z "$DONE" ]]
	    do
		if [[ $FAIL_COUNT -ge 5 ]]
		then
		    echo "Scenario $F, ${i}th iteration failed 5 times in a row. Exiting."
		    exit;
		fi
		
		./run-scenario.sh --scenario "$F --seed=$i"
		docker exec -u $USER $CONTAINER_ID lcov --directory /apollo/ --zerocounters

		_RUN_FILE=./data/log/planning.INFO
		_RUN_HASH=`md5sum $_RUN_FILE | cut -d' ' -f 1`

		run_success
		_res=$?
		
		# Mark metadata for junked run
		if [[ $_res != 0 ]]
		then
		    echo "Run $_RUN_HASH failed. Marking it as junk..."
		    mkdir -p ./data/metadata/$_RUN_HASH
		    touch ./data/metadata/$_RUN_HASH/junked
		    FAIL_COUNT=$((FAIL_COUNT+1))
		else
		    SUCCESSFUL_ITERATIONS=$((SUCCESSFUL_ITERATIONS+1))
		fi		
	    done
	    FAIL_COUNT=0
	    echo $SUCCESSFUL_ITERATIONS > ./data/metadata/$_RUN_HASH/run_number.txt
	done
    fi
    
done <./scenarios.txt

