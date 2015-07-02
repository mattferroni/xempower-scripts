#!/bin/bash

# in seconds
TESTS_LENGTH=120
TESTS_FOLDER=/home/matteo/workspace/tests

# Watt's up? Power Meter setup
WATTSUP=/home/matteo/workspace/watts-up/wattsup
WATTSUP_USB=ttyUSB0

# RAPL plot setup
RAPL_PLOT=/home/matteo/workspace/rapl-experiments/papi-5.4.1/rapl_plot

# PAPI
PAPI_SRC=/home/matteo/tools/papi-5.4.1/src

# Current date-time format (e.g.: 2013-07-07-16.10.47)
NOW=`/bin/date +"%Y-%m-%d-%H.%M.%S"`
CURRENT_FOLDER=$TESTS_FOLDER/make-papi-$NOW
TESTS_LENGTH_MICROS=$(echo "$TESTS_LENGTH*1000000" | bc)

# Create dir $CURRENT_FOLDER if !exists
if [ ! -d $CURRENT_FOLDER ]; then
	mkdir -p $CURRENT_FOLDER
fi

# Only Watts
echo "Storing wattsup infos (watts) for "$TESTS_LENGTH"s..."
$WATTSUP -c $TESTS_LENGTH $WATTSUP_USB watts -r > $CURRENT_FOLDER/wattsup-watts &

# RAPL via PAPI: TESTS_LENGTH at 100ms
echo "Storing RAPL infos (all) for "$TESTS_LENGTH"s, every 100ms..." 
$RAPL_PLOT 100000 $TESTS_LENGTH_MICROS $CURRENT_FOLDER/ &

echo "--- Both launched! Sleep for 5s before make clean..."
sleep 5s

cd $PAPI_SRC
echo "Now make clean..."
make clean > /dev/null
echo "--- make clean done. Sleep for 5s before make..."

sleep 5s

echo "Now make..."
make > /dev/null
echo "--- make done. Sleep for 5s before make clean..."

sleep 5s

echo "Now make clean..."
make clean > /dev/null
echo "--- make clean done. Sleep for 5s before make -j4..."

sleep 5s

echo "Now make -j4..."
make -j4 > /dev/null
echo "--- make -j4 done. Waiting for the end of the test..."

wait

chown -R matteo:matteo $TESTS_DIR*

echo ""
echo "Tests completed."