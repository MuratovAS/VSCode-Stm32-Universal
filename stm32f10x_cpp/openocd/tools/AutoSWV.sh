#!/bin/bash
clear;
echo "Auto monitoring SWV..."
echo -n > build/swv.log
sleep 1; 
while (true) 
do
 #clear;
 openocd/tools/itmdump/itmdump -f build/swv.log -d1
 echo -n > build/swv.log 
 sleep 3; # пауза в секундах
done;