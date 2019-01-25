#!/bin/bash
####################################################
####################LOCKFILE########################
LOCKDIR="/tmp/JeeRoomNodeDecoder-lock"
if mkdir "${LOCKDIR}" &>/dev/null; then
####################################################
yymmdd=`date "+%Y%m%d"`
/usr/bin/tail -n1 /etc/heyu/JeeRoomNodeDecoder.dat > /tmp/JeeRoomNodeDecoder.dat               # /tmp is a ram disk on RPi
read date time node light movement humidity temp  < /tmp/JeeRoomNodeDecoder.dat                # Read back last data stored
if [ "${yymmdd:6:2}" -ne "${date:8:2}" ] 
  then
  mv /etc/heyu/JeeRoomNodeDecoder.dat /etc/heyu/archive/JeeRoomNodeDecoder-${date:0:4}${date:5:2}${date:8:2}.dat
  touch /etc/heyu/JeeRoomNodeDecoder.dat
  mv /etc/heyu/JeeRoomNodeDecoder.skipped /etc/heyu/archive/JeeRoomNodeDecoder-${date:0:4}${date:5:2}${date:8:2}.skipped
  touch /etc/heyu/JeeRoomNodeDecoder.skipped
fi
#echo `date "+%Y/%m/%d %X"` $@ >> ./JeeRoomNodeDecoder.txt
	args=("$@")	# Assign to array
#
#     RoomNode
#      0  4  17 111 12 1 0
# args 0  1   2   3  4 5 6
#
#struct {
#	 byte command;		// ACK command return field
#    byte light;     // (arg 2) light sensor: 0..255
#    byte moved :1;  // (arg 3) motion detector: 0..1
#    byte humi  :7;  // (arg 3) humidity: 0..100
#    int temp   :10; // (arg 4)+(arg 4) temperature: -500..+500 (tenths)
#    byte lobat :1;  // (arg 5) supply voltage dropped under 3.1V: 0..1
#//    int voltage :13; //(arg 4)+(arg 5) AA-Board Battery voltage
#} payload;

let "command = ${args[1]}" # Get command byte
let "node = ${args[0]}"	   # Get node number
#let "node = $node & 31"   # strip ack/dst/ctl flags
let "light = ${args[2]}"   # Get light level
#
# let "timer = 4294967295" 	# maximum timer expected 255 255 255 255
let "movement = ${args[3]} & 1"       # Low order bit indicates movement
#let "movement = $movement / 128"     # Low order bit indicates movement
#
let "humidity = ${args[3]} >> 1"      # 
#let "humidity = $humidity & 127"     # Loose low order bit if present
#
let "temp = ${args[5]} & 3"	          # Clear all but top 2 bits
let "temp = temp << 8"                # Position bits 9&10
let "temp = temp + ${args[4]}"        # Add in bits 1-8
#
let "battery = ${args[5]} >> 7"

echo `date "+%Y/%m/%d %X"` $node $light $movement $humidity $temp $battery >> /etc/heyu/JeeRoomNodeDecoder.dat
#  
if [ -f /tmp/BME280.roomNode ] ;
	then
		read bmeTemp bmeHumidity bmePressure bmeVcc < /tmp/BME280.roomNode
		post "http://api.thingspeak.com/update?key=AG0FOXOMBA68DDOR&field1=$light&field2=$movement&field3=$humidity&field4=$temp&field5=$battery&field6=$bmeVcc&field7=$bmeHumidity&field8=$bmePressure"
		rm /tmp/BME280.roomNode
	else
		post "http://api.thingspeak.com/update?key=AG0FOXOMBA68DDOR&field1=$light&field2=$movement&field3=$humidity&field4=$temp&field5=$battery"
fi

if [[ $battery == 1 ]];
	then 
		who | awk '$1 == "john" { print $2 }' | while read pty; do echo "Sending to $pty"; echo $'\n'$'\x07'"Low Battery Node $node"  > /dev/$pty; done
fi

else
 echo `date "+%Y/%m/%d %X"` $@ >> /etc/heyu/JeeRoomNodeDecoder.skipped
#################################################################
rm -rf "${LOCKDIR}"
fi
#################################################################

