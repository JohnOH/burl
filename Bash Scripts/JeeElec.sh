#!/bin/bash
if [ -f /tmp/cumElec ] ;
	then
		read cumulative < /tmp/cumElec
		echo 0 > /tmp/cumElec
		if [ "$cumulative" -ne 0 ];
			then 		
			post "http://api.thingspeak.com/update?key=QA676KGFLDQ1B1JW&field3=$cumulative" > /dev/null 2>&1
		fi
	else
		echo 0 > /tmp/cumElec
fi
