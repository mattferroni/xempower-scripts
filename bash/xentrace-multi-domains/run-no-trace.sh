#!/bin/bash
#usage: ./run-no-trace.sh
#echo every command

# in seconds
TIME_SLACK=20

START=$(date +%s.%N)
echo $(date +%s.%N) " - Test started."

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

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo $(date +%s.%N) " - Duration: "$DIFF"s."