#!/bin/bash

# constant
XEN_SRC=/home/matteo/workspace/xen

echo "Making Xen..."
START=$(date +%s.%N)
cd $XEN_SRC
./configure --enable-stubdom
make -j4 world
sudo make install
sudo ldconfig -v
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo "--- Done in: "$DIFF"s"
