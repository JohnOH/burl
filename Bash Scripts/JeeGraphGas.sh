#!/bin/bash
if [ -f /tmp/GraphGas ] ;
	then
		read Ldate Ltime Lnode Lsequence Lcount Ltimer Ltemperature Lvoltage < /tmp/GraphGas
		tail /etc/heyu/JeeGasCounterDecoder.dat -n1 > /tmp/GraphGas
		read date time node sequence count timer temperature voltage < /tmp/GraphGas

		if [ $sequence -ne $Lsequence ] ;
			then
				let "used = $count - $Lcount"
#				wget -q -t 1 -O- "https://api.thingspeak.com/update?key=7XBDAG15IIQ5HWV9&field3=$used&field4=$temperature&field5=$voltage" > /dev/null 2>&1
				post "http://api.thingspeak.com/update?key=7XBDAG15IIQ5HWV9&field3=$used&field4=$temperature&field5=$voltage" > /dev/null 2>&1
#			else
#				wget -q -t 1 -O- "https://api.thingspeak.com/update?key=7XBDAG15IIQ5HWV9&field3=0" > /dev/null 2>&1
#				post "http://api.thingspeak.com/update?key=7XBDAG15IIQ5HWV9&field3=0" > /dev/null 2>&1
		fi
	else
		tail /etc/heyu/JeeGasCounterDecoder.dat -n1 > /tmp/GraphGas
fi
#/etc/heyu/JeeElec.sh
