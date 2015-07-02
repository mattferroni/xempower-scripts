#!/bin/bash

# in seconds
WATTSUP_LENGTH=60
TESTS_LENGTH=10
TESTS_FOLDER=/home/matteo/workspace/tests

# Watt's up? Power Meter setup
WATTSUP=/home/matteo/workspace/watts-up/wattsup
WATTSUP_USB=ttyUSB0

# RAPL plot setup
RAPL_PLOT=/home/matteo/workspace/rapl-experiments/papi-5.4.1/rapl_plot

# Current date-time format (e.g.: 2013-07-07-16.10.47)
NOW=`/bin/date +"%Y-%m-%d-%H.%M.%S"`
CURRENT_FOLDER=$TESTS_FOLDER/idle-parallel-$NOW
TESTS_LENGTH_MICROS=$(echo "$TESTS_LENGTH*1000000" | bc)

# Create dir $CURRENT_FOLDER if !exists
if [ ! -d $CURRENT_FOLDER ]; then
	mkdir -p $CURRENT_FOLDER
fi

# Only Watts
echo "Storing wattsup infos (watts) for "$WATTSUP_LENGTH"s..."
$WATTSUP -c $WATTSUP_LENGTH $WATTSUP_USB watts -r > $CURRENT_FOLDER/wattsup-watts &
echo "--- Launched. Waiting 5s before next test..."
sleep 5s

# RAPL via PAPI: TESTS_LENGTH at 100ms
echo "Storing RAPL infos (all) for "$TESTS_LENGTH"s, every 100ms..."
START=$(date +%s.%N)
$RAPL_PLOT 100000 $TESTS_LENGTH_MICROS $CURRENT_FOLDER/
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo "--- Done in: "$DIFF"s. Waiting 5s before next test..."
sleep 5s

# RAPL via PAPI: TESTS_LENGTH at 10ms
echo "Storing RAPL infos (all) for "$TESTS_LENGTH"s, every 10ms..."
START=$(date +%s.%N)
$RAPL_PLOT 10000 $TESTS_LENGTH_MICROS $CURRENT_FOLDER/
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo "--- Done in: "$DIFF"s. Waiting 5s before next test..."
sleep 5s

# RAPL via PAPI: TESTS_LENGTH at 1ms
echo "Storing RAPL infos (all) for "$TESTS_LENGTH"s, every 1ms..."
START=$(date +%s.%N)
$RAPL_PLOT 1000 $TESTS_LENGTH_MICROS $CURRENT_FOLDER/
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo "--- Done in: "$DIFF"s."

wait

chown -R matteo:matteo $TESTS_FOLDER*

echo ""
echo "Tests completed."