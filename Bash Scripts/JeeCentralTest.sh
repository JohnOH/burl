#!/bin/bash
echo "Start JeeCentralTest.sh" >> /tmp/JeeCentralTest
####################################################
####################LOCKFILE########################
LOCKDIR="/tmp/JeeCentralTest-lock"
if mkdir "${LOCKDIR}" &>/dev/null; then
####################################################
echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeeCentralTest.txt
yymmdd=`date "+%Y%m%d"`
#echo $yymmdd
	args=("$@")	# Assign to array
#     49 35 145 16 2 0 0 0 0 255 255 0  0    0   0   0   0 
# args 0  1   2  3  4   5 6  7  8   9  10   11  12  13  14  15
#
#     49 35 145 16  1   0 0 52 11 185   16 136  17  34  12 New  (-70dB)
#     62  8   0 49 32 255 0  0  0   0    0   0 244 255   0   0

# Extract 8 bits XX 145 16 2 0 0 0 0 255 255 0 0 0 0 0 0 (-70dB)
let "node = ${args[0]}"	# Get node number
let "node = $node&31" # strip ack/dst/ctl flags
#echo $node #>> /tmp/node
#
# Extract last command received via ACK
let "command = ${args[1]}"
#
# Extract 2 bits of packet type
let "type = ${args[2]} >> 6"
# Extract 2 bit setback indicator
let "setBack = ${args[2]} >> 4"
let "setBack = $setBack & 3" 
# Extract 6 bits of RX CRC error count
let "badCRC = ${args[2]} & 15" 
#
# Extract 4 bits 62 8 XX 16 2 0 0 0 0 255 255 0 0 0 0 0 0 (-70dB)
let "attempts = ${args[3]} & 15"	# Get attempt number, strip high order 4 bits
#echo ${args[1]} $attempts #>> /tmp/attempts
#
# Extract 4 bits 49 XX 16 2 0 0 0 0 255 255 0 0 0 0 0 0 (-70dB)
let "sequence = ${args[3]} >> 4"	# Get sequence number, loose low order 4 bits
#echo ${args[1]} $sequence #>> /tmp/sequence
#
# Extract battery voltage
let "Voltage = ${args[4]}"
# Extract Salus ID 49 145 XX 2 0 0 0 0 255 255 0 0 0 0 0 0 (-70dB)
#let "SalusID = ${args[5]}"
let "SalusID = (${args[6]} << 8) + ${args[5]}"
#echo $SalusID
# Extract Salus command 49 145 16 X 0 0 0 0 255 255 0 0 0 0 0 0 (-70dB)
let "SalusCommand = ${args[7]}" # 1 = ON & 2 = OFF
#echo $SalusCommand
#
# Extract Salus noise counter
let "SalusNoise = ${args[8]}"
#echo $SalusNoise
# Extract current temperature
let "currentTemp = (${args[10]} << 8) + ${args[9]}"
# Extract lowest temperature
let "lowestTemp = (${args[12]} << 8) + ${args[11]}"
# Extract target temperature
let "targetTemp = (${args[14]} << 8) + ${args[13]}"
 #
# Extract Cold Feed Temperature
let "ColdFeed = (${args[16]} << 8) + ${args[15]}"
# Extract Boiler Feed Temperature
let "BoilerFeed = (${args[18]} << 8) + ${args[17]}"
# Extract Central Heating Return Temperature
let "CHreturn = (${args[20]} << 8) + ${args[19]}"
# Extract Tank Coil Return Temperature
let "TCreturn = (${args[22]} << 8) + ${args[21]}"

# Collect latest temperature from RoomNode
/usr/bin/tail -n1 /etc/heyu/JeeRoomNodeDecoder.dat > /tmp/latestRoomNode.dat # /tmp is a ram disk on RPi
read date time RoomNode light movement humidity temperature  < /tmp/latestRoomNode.dat

# Collect latest temperature from RoomNode
/usr/bin/tail -n1 /etc/heyu/GasMeter > /tmp/GasMeter # /tmp is a ram disk on RPi
read date time GasMeter GasCount  < /tmp/GasMeter

echo `date "+%Y/%m/%d %X"` $node $command $type $setBack $badCRC $sequence $attempts $Voltage $SalusID $SalusCommand $SalusNoise $currentTemp $lowestTemp $targetTemp $ColdFeed $BoilerFeed $CHreturn $TCreturn $temperature $GasMeter >> /etc/heyu/JeeCentralTest.dat

#################################################################
rm -rf "${LOCKDIR}"
else
#echo "Finished"
echo `date "+%Y/%m/%d %X"` $@ >> /etc/heyu/JeeCentralTest.skipped
fi
#################################################################
#wget -q -O- "https://api.thingspeak.com/update?key=O64IA4X1ZIVU9DWN&field4=$Voltage&field5=$ColdFeed&field6=$BoilerFeed&field7=$CHreturn&field8=$TCreturn" > /dev/null 2>&1
#
