#!/bin/bash
# RX threshold change 208 209 103 1 0 0 345957
#                       3   4   5 6 7 8      9
# RX threshold change 210 211 38873 3 0 0 169910292
#                       3   4     5 6 7 8         9

if [ $# -eq 1 ]	# Arguments received as a single string?
	then
	set -- $@	# Chop it up
fi
	args=("$@")	# Assign to array
threshold="threshold"
if [[ "${args[1]}" == "$threshold" ]];
	then
        read prevRestarts prevSyncMatch prevGoodCRC< /tmp/rx_restarts.txt
        let "restarts = (${args[5]} - $prevRestarts)"
        let "syncMatch = (${args[6]} - $prevSyncMatch)"
        let "goodCRC = (${args[7]} - $prevGoodCRC)"
	let "SyncLessCRC = ($syncMatch - $goodCRC)"
	let "RSSIlessSync = ($restarts - $syncMatch)"
        echo "${args[5]} ${args[6]} ${args[7]}" > /tmp/rx_restarts.txt
	echo "`date "+%d/%m/%Y %X"` ${args[3]} ${args[4]} $restarts $syncMatch $goodCRC" >> /etc/heyu/rx.txt
#	wget -q -t 1 -O- "https://api.thingspeak.com/update?key=BTLO8PRRC6ZY0MJ1&field1=${args[4]}&field2=$restarts&field3=$syncMatch&field4=$goodCRC&field5=$SyncLessCRC&field6=$RSSIlessSync" > /dev/null 2>&1
	post "https://api.thingspeak.com/update?key=BTLO8PRRC6ZY0MJ1&field1=${args[4]}&field2=$restarts&field3=$syncMatch&field4=$goodCRC&field5=$SyncLessCRC&field6=$RSSIlessSync"
fi
