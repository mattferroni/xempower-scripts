#!/bin/bash

set -e

#add path in /etc/environment
HOME=/home/matteo

XEMPOWER_DIR=$HOME/xempower
SCHEDULE_DIR=$XEMPOWER_DIR/xen/common
SCHEDULE_FILE=$SCHEDULE_DIR/schedule.c
SCRIPTS_DIR=$HOME/workspace/scripts/bash/marc
START_XENTRACE_TEMPLATE=$SCRIPTS_DIR/start_xentrace_template
START_XENTRACE_SCRIPT=$SCRIPTS_DIR/start_xentrace.sh
TESTS_FOLDER=$HOME/workspace/tests/marc
MARC_SCRIPTS_DIR=$HOME/workspace/scripts/bash/marc
START_XENTRACE_TAIL=$SCHEDULE_DIR/xentrace_tail
START_DOMAIN=$SCRIPTS_DIR/start_domain.sh
STOP_DOMAIN=$SCRIPTS_DIR/stop_domain.sh
STOP_XENTRACE=$SCRIPTS_DIR/stop_xentrace.sh
PARSE_DATA=$SCRIPTS_DIR/parse_data.sh

#MARC DOMAIN VARIABLES
MARC_CFG=$HOME/vm/marc/marc.cfg

# WATTSUP variables
WATTSUP_USB="/dev/ttyUSB0"
WATTSUP=$HOME/workspace/watts-up/wattsup
WATTSUP_READER=$SCRIPTS_DIR/wattsup_reader
WATTUP_DATA_PARSER=$SCRIPTS_DIR/parser_wattsup_output.py
WATTSUP_START_LOG="echo '#L,W,3,I,,1;' > $WATTSUP_USB"
WATTSUP_LOW_LOAD="echo '#L,W,3,E,,3600;' > $WATTSUP_USB"
WATTSUP_GET_DATA="echo '#D,R,0;' > $WATTSUP_USB"
WATTSUP_CLEAR="echo '#R,W,0;' > $WATTSUP_USB"

EXECUTION_TIME=4080
MAX_ITERATION=7
CURRENT_USER=$(stat -c '%U' $HOME)
# Current date-time format (e.g.: 2013-07-07-16.10)
NOW=`/bin/date +"%Y-%m-%d-%H.%M"`
CURRENT_FOLDER=$TESTS_FOLDER/bench-hdd-$NOW
MAPPING_FILE=$CURRENT_FOLDER"/domain_mapping.csv"
WATTSUP_OUTPUT_TMP=$CURRENT_FOLDER"/watts-up-tmp"
WATTSUP_OUTPUT=$CURRENT_FOLDER"/wattsup-watts"
ITERATION_FILE=$TESTS_FOLDER/iteration

EMAIL_SENDER=$SCRIPTS_DIR/sender.py
RESTORE_FILES=$SCRIPTS_DIR/restore_schedules_file.sh

if [ ! -f $ITERATION_FILE ]; then
	echo 0 > $ITERATION_FILE
	cd $XEMPOWER_DIR
	rm $SCHEDULE_DIR/schedule.o
	sudo colormake -j8 xen | grep 'schedule' && sudo colormake install && sudo ldconfig -v
	sudo reboot
fi


if [ ! -d $CURRENT_FOLDER ]; then
	mkdir -p $CURRENT_FOLDER
fi

echo $(date +%s.%N) " - Starting xen..."
cd $XEMPOWER_DIR
sudo service xencommons restart
echo $(date +%s.%N) " - Xen started"

cd $MARC_SCRIPTS_DIR

echo $(date +%s.%N) " - Compiling Watt's up? Power Meter reader..."
gcc -o wattsup_reader wattsup_reader.c
echo $(date +%s.%N) " - Watt's up? Power Meter reader compiled"


echo $(date +%s.%N) " - Updating start_xentrace script..."
rm $START_XENTRACE_SCRIPT
cat $START_XENTRACE_TEMPLATE $START_XENTRACE_TAIL >> $START_XENTRACE_SCRIPT
chmod +x $START_XENTRACE_SCRIPT
echo $(date +%s.%N) " - start_xentrace script updated"

sleep 20

echo $(date +%s.%N) " - Starting Watt's up? Power Meter..."
sudo $WATTSUP -c 5 ttyUSB0 watts
sleep 5
eval ${WATTSUP_CLEAR}
sleep 1
eval ${WATTSUP_START_LOG}
echo $(date +%s.%N) " - Watt's up? Power Meter started."

sleep 5

echo $(date +%s.%N) " - Starting benchmarks Marc..."

echo $(date +%s.%N) " - Launching Marc domain..."
sudo xl create $MARC_CFG
sudo xl vcpu-pin marc 0 1
sudo xl vcpu-pin marc 1 2
MAPPING_MARC=$(sudo xl list marc |awk '{print $2}' | sed -n 2p)
echo "marc,"$MAPPING_MARC >> $MAPPING_FILE
echo $(date +%s.%N) " - Marc domain started"

echo $(date +%s.%N) " - Starting Xentrace..."
$START_XENTRACE_SCRIPT $CURRENT_FOLDER
START=$(date +%s.%N)
echo $(date +%s.%N) " - Xentrace started."

sleep 60

echo $(date +%s.%N) " - Sending commands to Marc domain..."
ssh marc@10.0.0.2 'screen -d -m stress --hdd 4 --timeout 300s'
echo $(date +%s.%N) " - Command sent"

sleep 300s

echo $(date +%s.%N) " - Stopping domain marc..."
ssh marc@10.0.0.2 'sudo halt'
echo $(date +%s.%N) " - Domain marc stopped."

sleep 5

echo $(date +%s.%N) " - Stopping Xentrace..."
$STOP_XENTRACE
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo $(date +%s.%N) " - Xentrace stopped. Duration: "$DIFF"s."


echo $(date +%s.%N) " - Stopping wattsup log..."
$WATTSUP_READER $WATTSUP_USB $WATTSUP_OUTPUT_TMP & 
sleep 1
eval ${WATTSUP_GET_DATA}
eval ${WATTSUP_LOW_LOAD}

echo $(date +%s.%N) " - Parsing trace data..."
$PARSE_DATA $CURRENT_FOLDER
echo $(date +%s.%N) " - CSV file produced."
python $WATTUP_DATA_PARSER $WATTSUP_OUTPUT_TMP $WATTSUP_OUTPUT
rm $WATTSUP_OUTPUT_TMP
sudo chown -R $CURRENT_USER:$CURRENT_USER $CURRENT_FOLDER

echo $(date +%s.%N) " - Compressing results..."
tar -zcvf $CURRENT_FOLDER.tar.gz $CURRENT_FOLDER
rm -r $CURRENT_FOLDER
sudo chown -R $CURRENT_USER:$CURRENT_USER $CURRENT_FOLDER.tar.gz
echo $(date +%s.%N) " - Results compressed"

VALUE_TO_APPEND=$(cat $ITERATION_FILE | sed 's/[^0-9]*//g')
NEXT_VALUE=$(($VALUE_TO_APPEND + 1))

if [ "$NEXT_VALUE" -le "$MAX_ITERATION" ]; then

	echo $(date +%s.%N) " - Changing schedule..."
	mv $SCHEDULE_FILE $SCHEDULE_FILE$VALUE_TO_APPEND
	mv $START_XENTRACE_TAIL $START_XENTRACE_TAIL$VALUE_TO_APPEND
	mv $SCHEDULE_FILE$NEXT_VALUE $SCHEDULE_FILE
	mv $START_XENTRACE_TAIL$NEXT_VALUE $START_XENTRACE_TAIL
	echo $(date +%s.%N) " - Schedule changed"

	echo $NEXT_VALUE > $ITERATION_FILE
	cd $XEMPOWER_DIR
	echo $(date +%s.%N) " - Making and Installing Xen..."

	python $EMAIL_SENDER

	rm $SCHEDULE_DIR/schedule.o
	sudo colormake -j8 xen | grep 'schedule' && sudo colormake install && sudo ldconfig -v
	echo $(date +%s.%N) " - Xen installation completed. Reboot"
	sudo reboot
else
	echo $(date +%s.%N) " - Restoring files..."
	rm $ITERATION_FILE
	$RESTORE_FILES $HOME $MAX_ITERATION
	echo $(date +%s.%N) " - Files restored"
	python $EMAIL_SENDER
fi



