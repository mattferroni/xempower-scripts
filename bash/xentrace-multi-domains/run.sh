#!/bin/bash
#usage: ./run.sh
#echo every command

# in seconds
TIME_SLACK=20
TESTS_LENGTH=110
TESTS_FOLDER=/home/matteo/workspace/tests

# Current date-time format (e.g.: 2013-07-07-16.10)
NOW=`/bin/date +"%Y-%m-%d-%H.%M"`
CURRENT_FOLDER=$TESTS_FOLDER/xentrace-to-rapl-$NOW

# Create dir $CURRENT_FOLDER if !exists
if [ ! -d $CURRENT_FOLDER ]; then
	mkdir -p $CURRENT_FOLDER
fi

echo $(date +%s.%N) " - Starting Watt's up? Power Meter..."
./start_wattsup.sh $TESTS_LENGTH $CURRENT_FOLDER
echo $(date +%s.%N) " - Watt's up? Power Meter started."

echo $(date +%s.%N) " - Starting Xentrace..."
./start_xentrace.sh $CURRENT_FOLDER
START=$(date +%s.%N)
echo $(date +%s.%N) " - Xentrace started."

sleep 5

echo $(date +%s.%N) " - Starting domain 1..."
./start_domain.sh 1 2
echo $(date +%s.%N) " - Domain 1 started."

sleep $TIME_SLACK

echo $(date +%s.%N) " - Starting domain 2..."
./start_domain.sh 2 1
echo $(date +%s.%N) " - Domain 2 started."

sleep $TIME_SLACK

echo $(date +%s.%N) " - Starting domain 3..."
./start_domain.sh 3 1
echo $(date +%s.%N) " - Domain 3 started."

sleep $TIME_SLACK

echo $(date +%s.%N) " - Stopping domain 1..."
./stop_domain.sh 1
echo $(date +%s.%N) " - Domain 1 stopped."

sleep $TIME_SLACK

echo $(date +%s.%N) " - Stopping domain 2..."
./stop_domain.sh 2
echo $(date +%s.%N) " - Domain 2 stopped."

sleep $TIME_SLACK

echo $(date +%s.%N) " - Stopping domain 3..."
./stop_domain.sh 3
echo $(date +%s.%N) " - Domain 3 stopped."

sleep 5

echo $(date +%s.%N) " - Stopping Xentrace..."
./stop_xentrace.sh 
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo $(date +%s.%N) " - Xentrace stopped. Duration: "$DIFF"s."

echo $(date +%s.%N) " - Parsing trace data..."
./parse_data.sh $CURRENT_FOLDER
echo $(date +%s.%N) " - CSV file produced."

chown -R matteo:matteo $CURRENT_FOLDER/*