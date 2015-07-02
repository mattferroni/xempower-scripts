#!/bin/bash
#usage: ./stop_xentrace.sh
#echo every command
set -x

sudo killall xentrace

echo "Parsing trace data..."
cat /home/matteo/traces/trace.data | xentrace_format /home/matteo/traces/rapl_trace_matlab.format >> /home/matteo/traces/rapl.csv
cat /home/matteo/traces/trace.data | xentrace_format /home/matteo/traces/pmc_trace_matlab.format >> /home/matteo/traces/pmc.csv
echo "CSV file produced."