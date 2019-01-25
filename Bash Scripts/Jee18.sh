#!/bin/bash
# Garden Shed
####################################################
####################LOCKFILE########################
LOCKDIR="/tmp/Jee18-lock"
if mkdir "${LOCKDIR}" &>/dev/null; then
####################################################
yymmdd=`date "+%Y%m%d"`
/usr/bin/tail -n1 /etc/heyu/Jee18.dat > /tmp/Jee18.dat               # /tmp is a ram disk on RPi
read date time node light movement humidity temp  < /tmp/Jee18.dat   # Read back last data stored
if [ "${yymmdd:6:2}" != "${date:8:2}" ] 
  then
  mv /etc/heyu/Jee18.dat /etc/heyu/archive/Jee18-${date:0:4}${date:5:2}${date:8:2}.dat
  touch /etc/heyu/Jee18.dat
  mv /etc/heyu/Jee18.skipped /etc/heyu/archive/Jee18-${date:0:4}${date:5:2}${date:8:2}.skipped
  touch /etc/heyu/Jee18.skipped
fi
#echo `date "+%Y/%m/%d %X"` $@ >> ./JeeRoomNodeDecoder.txt
	args=("$@")	# Assign to array
# args0 1 2 3 4 5  6   7  8   9 10
# OK 19 0 0 0 6 0 54 133 16 170 85 12 (71dB)
#struct {					//0		Offset, node #
#	byte command;			//1		ACK command return field
#    byte missedACK	:4;		//2
#    byte attempts	:4;		//2		Transmission attempts
#	byte count		:4;		//3		Packet count 
#    byte moved 		:1; //3		motion detector: 0..1
#    byte lobat 		:1; //3		supply voltage dropped under 3.1V: 0..1
#	byte spare2		:2;		//3    
#if BME280_PORT
#    uint32_t pressure:24;	//4&5&6
#endif 	   
#    byte light;     		//7		light sensor: 0..255
#    unsigned int humi:16;	//8&9	humidity: 0..100.00
#    int temp   		:16; //10&11	temperature: -5000..+5000 (hundredths)
#} payload;
#
#     RoomNode
#      19 0 15 0 87 140 1 0 87 2 185  8 115
# args  0 1  2 3  4   5 6 7  8 9  10 11  12
#

let "node = ${args[0]}"	   # Get node number
#let "node = $node & 31"   # strip ack/dst/ctl flags

let "command = ${args[1]}" # Get command byte

let "attempts = ${args[2]} >> 4" 
let "missedACK = ${args[2]} & 15"

let "movement = ${args[3]} & 128"
let "battery = ${args[3]} & 64"

let "count = ${args[3]}"
#let "count = $count >> 1"
#echo "Count10=$count"

let "pressure = ${args[6]} << 8"
let "pressure = $pressure + ${args[5]}"
let "pressure = $pressure << 8"
let "pressure = $pressure + ${args[4]}"

let "light = ${args[7]}"

let "humidity = ${args[9]} << 8"
let "humidity = $humidity + ${args[8]}"
#
let "temp = ${args[11]} << 8"
let "temp = temp + ${args[10]}"
let temp=$(($temp<<48)); let temp=$(($temp>>48)) # Preserve signed number
#
# 149 == 4.06v
# 108 is minimum that node stays active ~ 2.7v
let "vcc = ${args[12]}"
#
echo $temp $humidity $pressure $vcc > /tmp/Jee18-BME280.temp
#cp /tmp/BME280.temp /tmp/BME280.roomNode
#
echo `date "+%Y/%m/%d %X"` $node $light $command $attempts $missedACK $count $movement $battery $pressure $humidity $temp $vcc >> /etc/heyu/Jee18.dat
#  
#post "http://api.thingspeak.com/update?key=AG0FOXOMBA68DDOR&field1=$light&field2=$movement&field3=$humidity&field4=$temp&field5=$battery"

if [[ $vcc -le 90 ]];
	then 
		who | awk '$1 == "john" { print $2 }' | while read pty; do echo "Sending to $pty"; echo $'\n'$'\x07'"Low Battery Node $node $vcc"  > /dev/$pty; done
fi

else
 echo `date "+%Y/%m/%d %X"` $@ >> /etc/heyu/Jee18.skipped
#################################################################
rm -rf "${LOCKDIR}"
fi
#################################################################

