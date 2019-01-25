#!/bin/bash
#
cd /etc/heyu
killall RFxConsole
/bin/sleep 5
FILE=/etc/heyu/RFxConsole.new
if [ -f $FILE ]; then
   rm /etc/heyu/RFxConsole.old
   mv /etc/heyu/RFxConsole /etc/heyu/RFxConsole.old
   cp $FILE /etc/heyu/RFxConsole
   echo "New version of RFxConsole loaded" >> /etc/heyu/RFxConsole.txt
fi

echo "RFxConsole Restart on `date`"  >> /etc/heyu/RFxConsole.txt
nohup ./RFxConsole.sh >> /etc/heyu/RFxConsole.txt 2>&1
#
if [ -f $FILE ]; then
   rm /etc/heyu/RFxConsole.old
   mv /etc/heyu/RFxConsole /etc/heyu/RFxConsole.old
   cp $FILE /etc/heyu/RFxConsole
   echo "New version of RFxConsole loaded" >> /etc/heyu/RFxConsole.txt
fi

/usr/sbin/ssmtp itaide@googlemail.com << EOF
To: John O'Hare <itaide@googlemail.com>
Date: `date`
Subject: RFxConsole Restart #1-2 on `date -R`
Body:
------------------------
`tail /etc/heyu/RFxConsole.txt`
------------------------
`ps aux | grep RFxConsole`
------------------------

EOF
#

