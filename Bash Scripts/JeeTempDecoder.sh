#!/bin/bash
#if [ $# -ne 5 ]
#then
#  echo "Incorrect number ($#) of arguments $@" >> /etc/heyu/JeePowerSneakDecoder.err
#  exit 65
#fi
####################################################
#####             Sandhurst                    #####
####################LOCKFILE########################
LOCKDIR="/tmp/JeeTempDecoder-lock"
if mkdir "${LOCKDIR}" &>/dev/null; then
####################################################
	args=("$@")	# Assign to array
# args   0 1 2   3   4   5 6   7   8   9 10 11 12  13 14
#       36 0 0 113   0 255 0 178 161 251 52 33 133 14  0
#
let "node = ${args[0]}"	# Get node number
#
let "command = ${args[1]}"
#
let "badCRC = ${args[2]} & 15"
let "packetType = ${args[2]} >> 4"
#
let "attempts = ${args[3]} & 15"
let "count = ${args[3]} >> 4"
#
let "NoiseFloor = ${args[4]}"
#
let "failNoiseFloor = ${args[5]}"
#
let "failNoiseCount = ${args[6]}"
#
let "rxRssi = ${args[7]}"
#echo "rxRSSI $rxRssi"
# args   0 1 2   3   4   5 6   7   8   9 10 11 12  13 14
#       36 0 0 113   0 255 0 178 161 251 52 33 133 14  0
let "rxFei = ${args[9]} * 256"
let "rxFei = $rxFei + ${args[8]}"
#echo "rxFEI $rxFei"
#
#echo  "Temp: ${args[10]} ${args[11]} "

let "temp = ${args[11]} * 256"
let "temp = $temp + ${args[10]}"
#echo "Temp:$temp"
#
let "voltage = ${args[13]} * 256"
let "voltage = $voltage + ${args[12]}"
#echo "Voltage $voltage"
#
echo `date "+%Y/%m/%d %X"` $node $command $packetType $badCRC $attempts $count $NoiseFloor $failNoiseFloor $failNoiseCount $rxRssi $temp $voltage >> /etc/heyu/JeeTempDecoder.dat
wget -q -t 1 -O- "https://api.thingspeak.com/update?key=8M3XA5UWS5A1L1RN&field4=$temp&field6=$voltage&field7=$NoiseFloor&field8=$rxRssi" > /dev/null 2>&1
wget -q -t 1 -O- "https://api.thingspeak.com/update?key=O64IA4X1ZIVU9DWN&field3=$temp" > /dev/null 2>&1

rm -rf "${LOCKDIR}"
else
 echo `date "+%Y/%m/%d %X"` $# $@ >> /etc/heyu/JeeTempDecoder.skipped
fi
#################################################################
