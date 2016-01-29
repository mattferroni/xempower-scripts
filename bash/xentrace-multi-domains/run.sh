#!/bin/bash
#usage: ./run.sh
#echo every command

# in seconds
TIME_SLACK=20
TESTS_LENGTH=110
TESTS_FOLDER=$HOME/workspace/tests
WATTSUP_USB="/dev/ttyUSB0"
CURRENT_USER=$(stat -c '%U' $HOME)
WATTSUP_START_LOG="echo '#L,W,3,I,,1;' > $WATTSUP_USB"
WATTSUP_LOW_LOAD="echo '#L,W,3,E,,3600;' > $WATTSUP_USB"
WATTSUP_GET_DATA="echo '#D,R,0;' > $WATTSUP_USB"
WATTSUP_CLEAR="echo '#R,W,0;' > $WATTSUP_USB"

# Current date-time format (e.g.: 2013-07-07-16.10)
NOW=`/bin/date +"%Y-%m-%d-%H.%M"`
CURRENT_FOLDER=$TESTS_FOLDER/xentrace-to-rapl-$NOW
MAPPING_FILE=$CURRENT_FOLDER"/domain_mapping.csv"
WATTSUP_OUTPUT=$CURRENT_FOLDER"/watts-up"


# Create dir $CURRENT_FOLDER if !exists
if [ ! -d $CURRENT_FOLDER ]; then
	mkdir -p $CURRENT_FOLDER
fi

# Add label line to mapping file
echo "NAME_DOM,NUMBER_DOM">> $MAPPING_FILE

echo $(date +%s.%N) " - Starting Watt's up? Power Meter..."
eval ${WATTSUP_CLEAR}
sleep 1
eval ${WATTSUP_START_LOG}
echo $(date +%s.%N) " - Watt's up? Power Meter started."

echo $(date +%s.%N) " - Starting Xentrace..."
./start_xentrace.sh $CURRENT_FOLDER
START=$(date +%s.%N)
echo $(date +%s.%N) " - Xentrace started."

sleep 5

echo $(date +%s.%N) " - Starting domain 1..."
./start_domain.sh 1 2
echo $(date +%s.%N) " - Domain 1 started."
MAPPING_CO1=$(sudo xl list Co1 |awk '{print $2}' | sed -n 2p)
echo "Co1,"$MAPPING_CO1 >> $MAPPING_FILE

echo "Pinning dom 1"
sudo xl vcpu-pin Co1 0 1
sudo xl vcpu-pin Co1 1 2

sleep $TIME_SLACK

echo $(date +%s.%N) " - Starting domain 2..."
./start_domain.sh 2 1
echo $(date +%s.%N) " - Domain 2 started."
MAPPING_CO2=$(sudo xl list Co2 |awk '{print $2}' | sed -n 2p)
echo "Co2,"$MAPPING_CO2 >> $MAPPING_FILE

echo "Pinning dom 2"
sudo xl vcpu-pin Co2 0 2

sleep $TIME_SLACK

echo $(date +%s.%N) " - Starting domain 3..."
./start_domain.sh 3 1
echo $(date +%s.%N) " - Domain 3 started."
MAPPING_CO3=$(sudo xl list Co3 |awk '{print $2}' | sed -n 2p)
echo "Co3,"$MAPPING_CO3 >> $MAPPING_FILE
echo "Pinning dom 3"
sudo xl vcpu-pin Co3 0 3

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

echo $(date +%s.%N) " - Stopping wattsup log..."
./wattsup_reader $WATTSUP_USB $WATTSUP_OUTPUT & 
sleep 1
eval ${WATTSUP_GET_DATA}
eval ${WATTSUP_LOW_LOAD}

echo $(date +%s.%N) " - Parsing trace data..."
./parse_data.sh $CURRENT_FOLDER
echo $(date +%s.%N) " - CSV file produced."

sudo chown -R $CURRENT_USER:$CURRENT_USER $CURRENT_FOLDER
