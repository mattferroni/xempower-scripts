#!/bin/bash
#usage: ./start_xentrace.sh
#echo every command
set -x

echo "0x0100f001  CPU%(cpu)d  %(tsc)d (+%(reltsc)8d)  event (0x%(event)016x)  dom%(1)d, vCPU%(2)d, PKG=%(3)8d, PP0=%(4)8d, PP1=%(5)8d, DRAM=%(6)8d" > /home/matteo/traces/rapl_trace_human.format
echo "0x0100f001  %(tsc)d,%(cpu)d,%(1)d,%(2)d,%(3)d,%(4)d,%(5)d,%(6)d" > /home/matteo/traces/rapl_trace_matlab.format
echo "TSC,CPU,DOM,vCPU,PKG,PP0,PP1,DRAM" > /home/matteo/traces/rapl.csv

echo "0x0100f002  CPU%(cpu)d  %(tsc)d (+%(reltsc)8d)  event (0x%(event)016x)  dom%(1)d, vCPU%(2)d, UOPS_RETIRED.ALL=%(3)8d, UOPS_ISSUED.ANY=%(4)8d, UOPS_ISSUED.ANY-stalls=%(5)8d, RESOURCE_STALLS.ANY=%(6)8d" > /home/matteo/traces/pmc_trace_human.format
echo "0x0100f002  %(tsc)d,%(cpu)d,%(1)d,%(2)d,%(3)d,%(4)d,%(5)d,%(6)d" > /home/matteo/traces/pmc_trace_matlab.format
echo "TSC,CPU,DOM,vCPU,UOPS_RETIRED.ALL,UOPS_ISSUED.ANY,UOPS_ISSUED.ANY-stalls,RESOURCE_STALLS.ANY" > /home/matteo/traces/pmc.csv

sudo xentrace -D -e 0x0100f000 /home/matteo/traces/trace.data &