#!/bin/bash
#usage: ./start_xentrace.sh TEST_FOLDER
#echo every command
set -x

CURRENT_FOLDER=$1

# 
echo "0x0100f001  CPU%(cpu)d  %(tsc)d (+%(reltsc)8d)  event (0x%(event)016x)  dom%(1)d, vCPU%(2)d, PKG=%(3)8d, PP0=%(4)8d, PP1=%(5)8d, DRAM=%(6)8d" > $CURRENT_FOLDER/rapl_trace_human.format
echo "0x0100f001  %(tsc)d,%(cpu)d,%(1)d,%(2)d,%(3)d,%(4)d,%(5)d,%(6)d" > $CURRENT_FOLDER/rapl_trace_matlab.format
echo "TSC,CPU,DOM,vCPU,PKG,PP0,PP1,DRAM" > $CURRENT_FOLDER/rapl.csv

# TODO - Copy this to trace CTR0-2 (NOTE: TRACE_5D) - check 0x0100f002 ?
# ADDED BY ANDREA TO TRACE CTR0-2 
echo "0x0100f002  CPU%(cpu)d  %(tsc)d (+%(reltsc)8d)  event (0x%(event)016x)  dom%(1)d, vCPU%(2)d, INSTR_RETIRED.Any=%(3)8d, CPU_CLK_UNHALTED.Core=%(4)8d, CPU_CLK_UNHALTED.Ref=%(5)8d" > $CURRENT_FOLDER/ctr_trace_human.format
echo "0x0100f002  %(tsc)d,%(cpu)d,%(1)d,%(2)d,%(3)d,%(4)d,%(5)d" > $CURRENT_FOLDER/ctr_trace_matlab.format
echo "TSC,CPU,DOM,vCPU,INSTR_RETIRED.ANY,CPU_CLK_UNHALTED.CORE,CPU_CLK_UNHALTED" > $CURRENT_FOLDER/ctr.csv

# TODO - Update these references to PMC1-4 (NOTE: TRACE_6D) - check 0x0100f003 ?
echo "0x0100f003  CPU%(cpu)d  %(tsc)d (+%(reltsc)8d)  event (0x%(event)016x)  dom%(1)d, vCPU%(2)d, UOPS_RETIRED.ALL=%(3)8d, UOPS_ISSUED.ANY=%(4)8d, UOPS_ISSUED.ANY-stalls=%(5)8d, RESOURCE_STALLS.ANY=%(6)8d" > $CURRENT_FOLDER/pmc_trace_human.format
echo "0x0100f003  %(tsc)d,%(cpu)d,%(1)d,%(2)d,%(3)d,%(4)d,%(5)d,%(6)d" > $CURRENT_FOLDER/pmc_trace_matlab.format
echo "TSC,CPU,DOM,vCPU,UOPS_RETIRED.ALL,UOPS_ISSUED.ANY,UOPS_ISSUED.ANY-stalls,RESOURCE_STALLS.ANY" > $CURRENT_FOLDER/pmc.csv

echo "0x0100f005  CPU%(cpu)d  %(tsc)d (+%(reltsc)8d)  event (0x%(event)016x)  dom%(1)d, vCPU%(2)d, APERF_REG=%(3)8d, MPERF_REG=%(4)8d" > $CURRENT_FOLDER/freq_trace_human.format
echo "0x0100f005  %(tsc)d,%(cpu)d,%(1)d,%(2)d,%(3)d,%(4)d" > $CURRENT_FOLDER/freq_trace_matlab.format
echo "TSC,CPU,DOM,vCPU,APERF_REG,MPERF_REG" > $CURRENT_FOLDER/freq.csv


sudo xentrace -D -e 0x0100f000 $CURRENT_FOLDER/trace.data &