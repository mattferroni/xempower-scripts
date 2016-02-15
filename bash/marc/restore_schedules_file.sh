#!/bin/bash

set -e

HOME=$1
MAX_ITERATION=$2

XEMPOWER_DIR=$HOME/xempower
SCHEDULE_DIR=$XEMPOWER_DIR/xen/common
LAST_SCHEDULE=$SCHEDULE_DIR/schedule.c$MAX_ITERATION
FIRST_SCHEDULE=$SCHEDULE_DIR/schedule.c0
SCHEDULE_FILE=$SCHEDULE_DIR/schedule.c

START_XENTRACE_TAIL=$SCHEDULE_DIR/xentrace_tail
START_XENTRACE_TAIL_FIRST=$SCHEDULE_DIR/xentrace_tail0
START_XENTRACE_TAIL_LAST=$SCHEDULE_DIR/xentrace_tail$MAX_ITERATION


mv $SCHEDULE_FILE $LAST_SCHEDULE
mv $FIRST_SCHEDULE $SCHEDULE_FILE

mv $START_XENTRACE_TAIL $START_XENTRACE_TAIL_LAST
mv $START_XENTRACE_TAIL_FIRST $START_XENTRACE_TAIL