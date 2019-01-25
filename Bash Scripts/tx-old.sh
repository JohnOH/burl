#!/bin/bash
if [ $# -eq 1 ]	# Arguments received as a single string?
	then
	set -- $@	# Chop it up
fi
	args=("$@")	# Assign to array
# TX 161 -> ack i17 Posted and cleared 48
#      0  1   2   3      4   5       6  7
#echo "`date "+%d/%m/%Y %X"` ${args[0]}" >> /etc/heyu/tx.txt
echo `date "+%d/%m/%Y %X"` ${args[0]} ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} >> /etc/heyu/tx.txt

let "noiseFloor = ${args[0]}"

if [[ "${args[2]}" == "Busy" ]];
	then 
	echo `date "+%d/%m/%Y %X"` "$@" >> /etc/heyu/Busy.txt
	exit
elif [[ "${args[4]}" == "Aborted" ]];
        then 
        echo `date "+%d/%m/%Y %X"` "$@" >> Aborted.txt
        exit
elif [[ "${args[4]}" == "Posted" ]];
	then 
	echo `date "+%d/%m/%Y %X"` "$@" >> Posted.txt
        echo `date "+%d/%m/%Y %X"` "$@" >> /etc/heyu/RFxConsole.txt        
#		who | awk '$1 == "john" { print $2 }' | while read pty; do echo "Sending to $pty"; echo $'\n'$'\x07'`date '+%d/%m/%Y %X'` $@ > /dev/$pty; done
		who | awk '$1 == "john" { print $2 }' | while read pty; do echo $'\x07'`date '+%d/%m/%Y %X'` $@ > /dev/$pty; done
	exit
else
	echo `date "+%d/%m/%Y %X"` "$@" >> Posted-Unkown.txt
fi

