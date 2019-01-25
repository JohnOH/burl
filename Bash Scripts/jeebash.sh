#!/bin/bash
date +%s > /tmp/seconds
echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/jeebash.txt
#tail -n1 /etc/heyu/jeebash.txt
if [ $# -eq 1 ]	# Arguments received as a single string?
	then
	set -- $@	# Chop it up
fi
	args=("$@")	# Assign to array
TX="TX"
RX="RX"
ReInit="ReInit"
RFM69="RFM69x"
HASH0="0"
HASH1="1"
HASH0="2"
HASH1="3"
HASH0="4"
HASH1="5"

if [[ "${args[0]}" == "$RX" ]];
	then
	echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/rxArgs.txt
	/etc/heyu/rx.sh $@
	exit
elif [[ "${args[0]}" == "$TX" ]];
	then 
#	echo "$@" >> /etc/heyu/jeebash.txt
	/etc/heyu/tx.sh ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]}
	exit
elif [[ "${args[0]}" == "$RFM69" ]];
	then
	echo  `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/rfm69.txt
	echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/RFxConsole.txt
#	/etc/heyu/RFM69.sh ${args[0]} ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} \
#						${args[9]} ${args[10]} ${args[11]} ${args[12]} ${args[13]} ${args[14]} ${args[15} ${args[16]} \
#						${args[17]} ${args[18]} &
	exit
elif [[ "${args[0]}" == "$ReInit" ]];
	then 
	echo `date "+%d/%m/%Y %X"` "$@" >> /etc/heyu/ReInit.txt
	exit
elif [[ "${args[0]}" == "OK" ]];
	then
	#
	#     OK 16 5 254 33 0 0 245 10 0 0
	# args 0  1 2   3  4 5 6   7  8 9 A
	#
	#The node number occupies 5 bits.

	#The A bit (ACK) 32 indicates whether this packet wants to get an ACK back. The C bit needs to be zero in this case (the name is somewhat confusing).

	#The D bit (DST) 64 indicates whether the node ID specifies the destination node or the source node. For packets sent to a specific node, DST = 1. For broadcasts, DST = 0, in which case the node ID refers to the originating node.

	#The C bit (CTL) 128 is used to send ACKs, and in turn must be combined with the A bit set to zero.

	# Get node number
	let node=${args[1]}
	#let "node=$node&159" # strip dst and ack flags
#	echo $@ >> args.txt
#	echo $node >> node.txt
	#
	# If ctl bit is set node will not match below - ignore ACK returns
	case $node in
	18) /etc/heyu/Jee18.sh ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]} \
                                    ${args[10]} ${args[11]} ${args[12]} ${args[13]} &
    #                                echo "After" > /tmp/After
									echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/i18.txt
	;;
	50) /etc/heyu/Jee18.sh ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]} \
                                    ${args[10]} ${args[11]} ${args[12]} ${args[13]} &
    #                                echo "After" > /tmp/After
									echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/i18.txt
	;;
	19) /etc/heyu/Jee19.sh ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]} \
                                    ${args[10]} ${args[11]} ${args[12]} ${args[13]} &
    #                                echo "After" > /tmp/After
									echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/i19.txt
	;;
	21)  /etc/heyu/JeeRoomNodeDecoder.sh ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]} \
                                    ${args[10]} ${args[11]} ${args[12]} ${args[13]} &
                                   echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeeRoomNodeDecoder.txt                                    
	;;
	53)  /etc/heyu/JeeRoomNodeDecoder.sh ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]} \
                                    ${args[10]} ${args[11]} ${args[12]} ${args[13]} &
                                   echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeeRoomNodeDecoder.txt                                    
	;;
	4)  /etc/heyu/JeeTempDecoder.sh  ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]} \
                                 ${args[10]} ${args[11]} ${args[12]} ${args[13]} ${args[14]} ${args[15]} ${args[16]} ${args[17]} &
                                   echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeeTempDecoder.txt                                    
	;;
	36) /etc/heyu/JeeTempDecoder.sh  ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]} \
                                 ${args[10]} ${args[11]} ${args[12]} ${args[13]} ${args[14]} ${args[15]} ${args[16]} ${args[17]} &
                                   echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeeTempDecoder.txt
	;;
	131) 
	;;
	70)  /etc/heyu/JeePowerSneakDecoder.sh ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]} \
                                    ${args[10]} ${args[11]} ${args[12]} ${args[13]} &
                                   echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeePowerSneakDecoder.txt                                    
	;;
	8)  /etc/heyu/JeePowerSneakDecoder.sh ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]} \
                                    ${args[10]} ${args[11]} ${args[12]} ${args[13]} &
                                   echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeePowerSneakDecoder.txt                                    
	;;
	15) /etc/heyu/JeeGasCounterDecoder.sh ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]}
                                    echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeeGasCounterDecoder.txt
									/etc/heyu/Outside.sh ${args[7]}                                    
	;;
	47) /etc/heyu/JeeGasCounterDecoder.sh ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]}
                                	echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeeGasCounterDecoder.txt
									/etc/heyu/Outside.sh ${args[7]}                                    
	;;
#	143) 
#	;;
	17) /etc/heyu/JeeCentralMonitor.sh $@ &
	#                                   echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeeCentralMonitor.txt
	;;
	49) /etc/heyu/JeeCentralMonitor.sh $@ &
	#                                   echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeeCentralMonitor.txt
	;;
#	145) 
#	;;
	22) 
	# /etc/heyu/JeeCentralTest.sh ${args[1]} ${args[2]} ${args[3]} ${args[4]} ${args[5]} ${args[6]} ${args[7]} ${args[8]} ${args[9]} ${args[10]} ${args[11]} ${args[12]} ${args[13]} ${args[14]} ${args[15]} ${args[16]} ${args[17]} ${args[18]} ${args[19]} ${args[20]} ${args[21]} ${args[22]} ${args[23]}  &
	#                                   echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/JeeCentralTest.txt
	;;
#	54)
#	;;
	*)  echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/jeebash.err
	echo `date "+%d/%m/%Y %X"` Unknown $@ >> /etc/heyu/RFxConsole.txt
	;;
	esac
	else
		echo `date "+%d/%m/%Y %X"` $@ >> /etc/heyu/hash.txt
	fi
