#!/bin/bash
#usage: ./parse_data.sh TEST_FOLDER
#echo every command
set -x

CURRENT_FOLDER=$1

echo "Parsing trace data..."
cat $CURRENT_FOLDER/trace.data | xentrace_format $CURRENT_FOLDER/rapl_trace_matlab.format >> $CURRENT_FOLDER/rapl.csv
cat $CURRENT_FOLDER/trace.data | xentrace_format $CURRENT_FOLDER/pmc_trace_matlab.format >> $CURRENT_FOLDER/pmc.csv
echo "CSV file produced."