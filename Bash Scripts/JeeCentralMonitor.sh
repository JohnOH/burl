#!/bin/bash
#echo "Start JeeCentralMonitor.sh" >> /tmp/JeeCentralMonitor
####################################################
####################LOCKFILE########################
LOCKDIR="/tmp/JeeCentralMonitor-lock"
if mkdir "${LOCKDIR}" &>/dev/null; then
####################################################
echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeeCentralMonitor.txt
#echo `date "+%d/%m/%Y %X"` $@
yymmdd=`date "+%Y%m%d"`
#echo $yymmdd
	args=("$@")	# Assign to array
#     OK 49 35 145 16 2 0 0 0 0 255 255 0  0    0   0   0   0 
# args 0  1  2   3  4 5 6 7 8 9  10 11 12 13   14  15  16  17
#
#     OK 49 35 145 16  1   0 0 52 11 185   16 136  17  34  12 New  (-70dB)
#     OK 62  8   0 49 32 255 0  0  0   0    0   0 244 255   0   0

# Extract 8 bits XX 145 16 2 0 0 0 0 255 255 0 0 0 0 0 0 (-70dB)
let "node = ${args[1]}"	# Get node number
let "node = $node&31" # strip ack/dst/ctl flags
#echo $node #>> /tmp/node
#
# Extract last command received via ACK
let "command = ${args[2]}"
#
# Extract 2 bits of packet type
#let "type = 0"
let "type = ${args[3]} >> 6"
let "type = $type + 0"
#echo "`date "+%Y/%m/%d %X"`"#"$type"#""
# Extract 2 bit setback indicator
let "setBack = ${args[3]} >> 5"
let "setBack = $setBack & 1" 
# Extract 6 bits of RX CRC error count
let "badCRC = ${args[3]} & 15" 
#
# Extract 4 bits 62 8 XX 16 2 0 0 0 0 255 255 0 0 0 0 0 0 (-70dB)
let "attempts = ${args[4]} & 15"	# Get attempt number, strip high order 4 bits
#echo ${args[1]} $attempts #>> /tmp/attempts
#
# Extract 4 bits 49 XX 16 2 0 0 0 0 255 255 0 0 0 0 0 0 (-70dB)
let "sequence = ${args[4]} >> 4"	# Get sequence number, loose low order 4 bits
#echo ${args[1]} $sequence #>> /tmp/sequence
#
# Extract battery voltage
let "Voltage = ${args[5]}"
# Extract Salus ID 49 145 XX 2 0 0 0 0 255 255 0 0 0 0 0 0 (-70dB)
#let "SalusID = ${args[5]}"
let "SalusID = (${args[7]} << 8) + ${args[6]}"
#echo $SalusID
# Extract Salus command 49 145 16 X 0 0 0 0 255 255 0 0 0 0 0 0 (-70dB)
let "SalusCommand = ${args[8]}" # 32 = ON & 0 = OFF
#echo $SalusCommand
#
# Extract Salus noise counter
let "SalusNoise = ${args[9]}"
#echo $SalusNoise
# Extract current temperature
let "currentTemp = (${args[11]} << 8) + ${args[10]}"
# Extract lowest temperature
let "lowestTemp = (${args[13]} << 8) + ${args[12]}"
# Extract target temperature
let "targetTemp = (${args[15]} << 8) + ${args[14]}"
#
# Check for temperature overrun, underrun or match
let "misMatch = 0"
if [ $targetTemp -ne $lowestTemp ]
    then 
    let "misMatch =  ($currentTemp - $targetTemp) / 10"     
fi

#
# Extract Cold Feed Temperature
let "ColdFeed = (${args[17]} << 8) + ${args[16]}"
# Extract Boiler Feed Temperature
let "BoilerFeed = (${args[19]} << 8) + ${args[18]}"
# Extract Central Heating Return Temperature
let "CHreturn = (${args[21]} << 8) + ${args[20]}"
# Extract Tank Coil Return Temperature
let "HWTankTemp = (${args[23]} << 8) + ${args[22]}"
# Extract Boiler Target
let "BTarget = (${args[25]} << 8) + ${args[24]}"

let "Delta=($BoilerFeed - $CHreturn)"
Delta=`echo "scale=2;$Delta / 100" | bc -l | sed -e 's/^-\./-0./' -e 's/^\./0./'`
#echo `date "+%Y/%m/%d %X"` $CHreturn $BoilerFeed $Delta >> /etc/heyu/CH-Delta.txt

# Collect latest temperature from RoomNode
/usr/bin/tail -n1 /etc/heyu/JeeRoomNodeDecoder.dat > /tmp/latestRoomNode.dat # /tmp is a ram disk on RPi
read date time RoomNode light movement humidity temperature  < /tmp/latestRoomNode.dat

# Collect latest temperature from RoomNode
/usr/bin/tail -n1 /etc/heyu/GasMeter > /tmp/GasMeter # /tmp is a ram disk on RPi
read date time GasMeter GasCount  < /tmp/GasMeter

# Get current Raspi temperaature
#let raspiTemp=`cat /sys/class/thermal/thermal_zone0/temp`
echo `date "+%Y/%m/%d %X"` $node $command $type $setBack $badCRC $sequence $attempts $Voltage $SalusID $SalusCommand $SalusNoise $currentTemp $lowestTemp $targetTemp $ColdFeed $BoilerFeed $CHreturn $HWTankTemp $tempShederature $GasMeter $raspiTemp >> /etc/heyu/JeeCentralMonitor.dat
#            0        1      2      3      4       5        6        7         8         9       10        11             12           13          14          15         16         17         18         19        20           21       22
# Collect latest noise floor from tx.sh
# /usr/bin/tail -n1 /etc/heyu/tx.txt > /tmp/tx.txt # /tmp is a ram disk on RPi
# read date time noiseFloor < /tmp/tx.txt
# echo "$noiseFloor" > /tmp/noiseFloor


if [ -f /tmp/BME280.temp ] ;
	then
		read bmeTemp bmeHumidity bmePressure < /tmp/BME280.temp
		post "http://api.thingspeak.com/update?key=O64IA4X1ZIVU9DWN&field1=$bmeTemp&field2=$setBack&field3=$BTarget&field4=$misMatch&field5=$ColdFeed&field6=$BoilerFeed&field7=$Delta&field8=$HWTankTemp" # >> /etc/heyu/JeeCentral1.post
		rm /tmp/BME280.temp
	else
		post "http://api.thingspeak.com/update?key=O64IA4X1ZIVU9DWN&field2=$setBack&field3=$BTarget&field4=$misMatch&field5=$ColdFeed&field6=$BoilerFeed&field7=$Delta&field8=$HWTankTemp" # >> /etc/heyu/JeeCentral1.post
fi

#let "ret = $?"
#if [ "$ret" -ne "0" ] ;
#  then
#  echo `date "+%Y/%m/%d %X "` "One $ret" >> /etc/heyu/JeeCentralMonitor.dat
#fi

#if [ "$type" -gt "1" ] ;
#  then 
#  wget -q -t 1 -O- "https://api.thingspeak.com/update?key=8M3XA5UWS5A1L1RN&field1=$currentTemp&field2=$lowestTemp&field3=$targetTemp" > /dev/null 2>&1

if [ -f /tmp/Jee18-BME280.temp ] ;
	then
		/usr/bin/tail -n1 /tmp/Jee18-BME280.temp > /tmp/Jee18.dat       # /tmp is a ram disk on RPi
		read tempShed humidity pressure vcc < /tmp/Jee18.dat                # Read back last data stored
		tempShed=`echo "scale=2;$tempShed / 100" | bc -l | sed -e 's/^-\./-0./' -e 's/^\./0./'`
		post "http://api.thingspeak.com/update?key=8M3XA5UWS5A1L1RN&field1=$currentTemp&field2=$lowestTemp&field3=$targetTemp&field4=$type&field5=$sequence&field6=$attempts&field7=$badCRC&field8=$tempShed" # | grep Status >> /etc/heyu/JeeCentral2.post
		rm /tmp/Jee18-BME280.temp
	else
		post "http://api.thingspeak.com/update?key=8M3XA5UWS5A1L1RN&field1=$currentTemp&field2=$lowestTemp&field3=$targetTemp&field4=$type&field5=$sequence&field6=$attempts&field7=$badCRC" # | grep Status >> /etc/heyu/JeeCentral2.post
fi	
#  if [ "$ret" -ne "0" ] ;
#    then
#    echo `date "+%Y/%m/%d %X"` "Two $ret" >> /etc/heyu/JeeCentralMonitor.dat
#  fi
#fi

#################################################################
rm -rf "${LOCKDIR}"
else
#echo "Finished"
echo `date "+%Y/%m/%d %X"` $@ >> /etc/heyu/JeeCentralMonitor.skipped
#################################################################
fi
#
