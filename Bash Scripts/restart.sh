#!/bin/bash
cd /etc/heyu
killall RFxConsole
/bin/sleep 5
FILE=/etc/heyu/RFxConsole.new
if [ -f $FILE ]; then
   rm /etc/heyu/RFxConsole.old
   mv /etc/heyu/RFxConsole /etc/heyu/RFxConsole.old
   mv $FILE /etc/heyu/RFxConsole
   echo "`date` New version of RFxConsole loaded" >> /etc/heyu/RFxConsole.txt
fi

echo "`date` RFxConsole Restart"  >> /etc/heyu/RFxConsole.txt
sudo systemctl disable serial-getty@ttyUSB*.service
stty -F /dev/ttyUSB* -echok -echoctl hupcl hup
nohup ./RFxConsole.sh >> /etc/heyu/RFxConsole.txt 2>&1
#
if [ -f $FILE ]; then
   rm /etc/heyu/RFxConsole.old
   mv /etc/heyu/RFxConsole /etc/heyu/RFxConsole.old
   mv $FILE /etc/heyu/RFxConsole
   echo "New version of RFxConsole loaded" >> /etc/heyu/RFxConsole.txt
fi

/usr/sbin/ssmtp itaide@googlemail.com << EOF
To: John O'Hare <itaide@googlemail.com>
Date: `date`
From: RasPi1-2 <raspi1-2@it-aide.net>
Subject: RFxConsole Restart #1-2 on `date -R`: restart.sh
Body:
------------------------
`tail /etc/heyu/RFxConsole.txt`
------------------------
`ps aux | grep RFxConsole`
------------------------

EOF
#
sleep 5
/usr/bin/jee 2U190R159T
