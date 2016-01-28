#!/bin/bash
#usage: ./start_wattsup.sh TESTS_LENGTH TEST_FOLDER
#echo every command
set -x

TESTS_LENGTH=$1
CURRENT_FOLDER=$2

# Watt's up? Power Meter setup
WATTSUP=$HOME/workspace/watts-up/wattsup
WATTSUP_USB=ttyUSB0

# Start tracing
sudo $WATTSUP -c $TESTS_LENGTH $WATTSUP_USB watts > $CURRENT_FOLDER/wattsup-watts &
