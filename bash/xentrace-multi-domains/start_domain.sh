#!/bin/bash
#usage: ./start DOMAIN# #CPUS
#echo every command
set -x
HOME_FOLDER=$HOME
DOM=$1
CPUS=$2
#Start DomU
# sudo xl create /home/matteo/vm/co$DOM/domain_config vcpus=$CPUS maxvcpus=$CPUS
sudo xl create $HOME_FOLDER/vm/co$DOM/domain_config