#!/bin/bash
# RX Stats 200 13229 7 7 108 108 2952981 1431 13229 [1 223 0 13215] [2 157 0 2] [3 141 0 2] [5 102 0 10]
#            2     3 4 5   6   7       8    9    10
# RX Stats 180 504 71 71 54 450 10606 621 0 54 [1 196 10 0 49] [2 194 20 0 5]
#            2   3  4  5  6   7     8  9 10 11
#2 Threshold in use
#3 RSSIrestart count
#4 syncMatch count
#5 goodCRC count
#6 restartRate
#7 maxRestartRate
#8 cumRSSI
#9 cumFEI
#10 cumCount
#
# [1 196 10 0 49] [2 194 20 0 5]
# [0   1  2 3  4]
#0 Auto LNA used on restart
#1 Average RSSI in sample period
#2 Average FEI in sample period
#3 Number of zero FEI in sample period 
#4 Number of restarts in sample period
#
if [ $# -eq 1 ]	# Arguments received as a single string?
	then
	set -- $@	# Chop it up
fi
	args=("$@")	# Assign to array
Stats="Stats"
if [[ "${args[1]}" == "$Stats" ]];
	then
        let "threshold = ${args[2]}"	
        let "restarts = ${args[3]}"
#        let "syncLessCRC = ${args[4]} - ${args[5]}"
		let "zeroFEI = ${args[10]}"
        let "goodCRC = ${args[5]}"
		let "rate = ${args[6]}"
		let "maxRate = ${args[7]}"
		if [[ "${args[11]}" -ne 0 ]];
			then
			let "avgRSSI = ${args[8]} / ${args[11]}"
			avgRSSI=$(bc <<< "scale=1;$avgRSSI/-2")
			let "avgFEI = ${args[9]} / ${args[11]}"
		else
			unset avgRSSI
			unset avgFEI
		fi
		echo "`date "+%d/%m/%Y %X"` ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]} ${args[10]} ${args[11]} $avgRSSI $avgFEI" >> /etc/heyu/rx_stats.txt
		post "http://api.thingspeak.com/update?key=BTLO8PRRC6ZY0MJ1&field1=$threshold&field2=$restarts&field3=$zeroFEI&field4=$goodCRC&field5=$rate&field6=$maxRate&field7=$avgRSSI&field8=$avgFEI"
		if [ "$rate" -lt "500" ];
			then
			echo "`date "+%d/%m/%Y %X"` $rate ${args[12]} ${args[13]} ${args[14]} ${args[15]} ${args[16]} ${args[17]} ${args[18]} ${args[19]} ${args[20]} ${args[21]} ${args[22]} ${args[23]} ${args[24]} ${args[25]} ${args[26]} ${args[27]} ${args[28]} ${args[29]} ${args[30]} ${args[31]} ${args[32]}" >> /etc/heyu/low.rate
		else	
			echo "`date "+%d/%m/%Y %X"` $rate ${args[12]} ${args[13]} ${args[14]} ${args[15]} ${args[16]} ${args[17]} ${args[18]} ${args[19]} ${args[20]} ${args[21]} ${args[22]} ${args[23]} ${args[24]} ${args[25]} ${args[26]} ${args[27]} ${args[28]} ${args[29]} ${args[30]} ${args[31]} ${args[32]}" >> /etc/heyu/high.rate
		fi
fi
