#!/bin/bash
#usage: ./stop DOMAIN#
#echo every command
set -x

DOM=$1
#Stop DomU
sudo xl destroy Co$DOM