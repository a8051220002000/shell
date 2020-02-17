#!/bin/bash
var=`cat list5.txt|wc -l`
while [ $var != 0 ]
do
	for line in cat /root/list5.txt
	do
	echo "start $line"
	sshpass -p 密碼 ssh root@$line 'df'
	echo "end $line"
	sleep 1
	var=$(($var-1))
	done
done
