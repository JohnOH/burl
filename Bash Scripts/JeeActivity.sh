#!/bin/bash
if [ -f /tmp/seconds ] ;
	then
		read  lastLtime < /tmp/seconds
		let "thisLtime = `date +%s` "
		let "thisLtime = $thisLtime - 6 "
		echo $lastLtime
		echo $thisLtime
		if [ $thisLtime -lt $lastLtime ] ;
			then
			echo "Less than"
			else
			echo "More than"
		else
			echo "jeebash.sh hasn't set /tmp/seconds" >> /etc/heyu/RFxConsole.txt
		fi
fi
