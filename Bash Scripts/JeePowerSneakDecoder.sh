#!/bin/bash
####################################################
#####             Sandhurst                    #####
####################LOCKFILE########################
LOCKDIR="/tmp/JeePowerSneakDecoder-lock"
if mkdir "${LOCKDIR}" &>/dev/null; then
####################################################
	args=("$@")	# Assign to array
#     OK 7 117 134 201 26 65
# args   0   1   2   3  4  5 
#
let "node = ${args[0]}"	# Get node number
let "count = ${args[1]}"
let "voltage = 27900 / ${args[2]}"
if [ -f /tmp/cumElec ] ;
	then
		read cumulative < /tmp/cumElec
		let "cumulative = $cumulative + $voltage"
		echo $cumulative > /tmp/cumElec
	else
		echo $voltage > /tmp/cumElec
		let "cumulative = $voltage"		
fi
echo `date "+%Y/%m/%d %X"` $node $count $voltage $minV $cumulative >> /etc/heyu/JeePowerSneakDecoder.dat
#wget -q -O- "https://api.thingspeak.com/update?key=8M3XA5UWS5A1L1RN&field5=$voltage" > /dev/null 2>&1
rm -rf "${LOCKDIR}"
else
 echo `date "+%Y/%m/%d %X"` $# $@ >> /etc/heyu/JeePowerSneakDecoder.skipped
fi
