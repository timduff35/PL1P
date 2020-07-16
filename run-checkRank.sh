#!/bin/bash

# This script runs several M2 processes 
# checking the rank of the forward map for all "candidate" PL1Ps

maxM2=3
for i in {0..143}
do
    ready=false
    while [ "$ready" = false ] 
    do 
	a=($(ps -a | grep M2 | wc -l))
	lines=${a[0]}
	echo "# M2 processes = "$lines
	if [ $lines -lt $maxM2 ]; then 
	    ready=true
	else
	    sleep 5	    
	fi
    done
    input_dir=$(printf "%03d/" $i)
    (cd $input_dir ; pwd ; echo "starting check in " $input_dir ; nohup M2 --script ../checkPL1P.m2 ; rm nohup.out; cd .. ) & 
    sleep 1
done
