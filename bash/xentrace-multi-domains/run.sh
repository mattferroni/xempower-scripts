#!/bin/bash

TIME_SLACK=20

echo "Starting Xentrace..."
./start_xentrace.sh
echo "Xentrace started."

sleep 2

echo "Starting domain 1..."
./start_domain.sh 1 2
echo "Domain 1 started."

sleep $TIME_SLACK

echo "Starting domain 2..."
./start_domain.sh 2 1
echo "Domain 2 started."

sleep $TIME_SLACK

echo "Starting domain 3..."
./start_domain.sh 3 1
echo "Domain 3 started."

sleep $TIME_SLACK

echo "Stopping domain 1..."
./stop_domain.sh 1
echo "Domain 1 stopped."

sleep $TIME_SLACK

echo "Stopping domain 2..."
./stop_domain.sh 2
echo "Domain 2 stopped."

sleep $TIME_SLACK

echo "Stopping domain 3..."
./stop_domain.sh 3
echo "Domain 3 stopped."

sleep 2

echo "Stopping Xentrace..."
./stop_xentrace.sh
echo "Xentrace stopped."

echo "Parsing trace data..."
./parse_data.sh
echo "CSV file produced."