#!/bin/bash

valid=true
count=10
while [ $valid ]
do
    sleep 1
    echo $count
    if [ $count -eq 0 ];
    then
        hello
	break
    fi
    ((count--))
done
