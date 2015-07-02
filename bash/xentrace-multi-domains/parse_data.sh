#!/bin/bash
#usage: ./parse_data.sh
#echo every command
set -x

cat /home/matteo/traces/rapl.trace | xentrace_format /home/matteo/traces/rapl_trace_matlab.format >> /home/matteo/traces/rapl.csv