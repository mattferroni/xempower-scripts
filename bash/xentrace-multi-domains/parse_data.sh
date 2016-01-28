#!/bin/bash
#usage: ./parse_data.sh TEST_FOLDER
#echo every command
set -x

CURRENT_FOLDER=$1

echo "Parsing trace data..."
cat $CURRENT_FOLDER/trace.data | xentrace_format $CURRENT_FOLDER/rapl_trace_matlab.format >> $CURRENT_FOLDER/rapl.csv
cat $CURRENT_FOLDER/trace.data | xentrace_format $CURRENT_FOLDER/pmc_trace_matlab.format >> $CURRENT_FOLDER/pmc.csv
#ADDED BY ANDREA TO TRACE CRT REGISTERS
cat $CURRENT_FOLDER/trace.data | xentrace_format $CURRENT_FOLDER/ctr_trace_matlab.format >> $CURRENT_FOLDER/ctr.csv
cat $CURRENT_FOLDER/trace.data | xentrace_format $CURRENT_FOLDER/freq_trace_matlab.format >> $CURRENT_FOLDER/freq.csv
echo "CSV file produced."
