#!/bin/bash

TIME_SLACK=10

echo $(date +%s.%N) " - Starting Xentrace..."
./start_xentrace.sh
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
./parse_data.sh
echo $(date +%s.%N) " - CSV file produced."