#!/bin/bash
cd /etc/heyu
killall RFxConsole
#chmod 0777 /dev/ttyUSB0
#chmod 0777 /dev/JeeLink
#chown john /dev/JeeLink
#chown john /dev/ttyUSB0
chgrp dialout /dev/ttyUSB*
systemctl disable serial-getty@ttyUSB*.service
#chgrp dialout /dev/JeeLink
#stty -F /dev/JeeLink -echok -echoctl hupcl hup
stty -F /dev/ttyUSB* -echok -echoctl hupcl hup
echo "`date` Reboot" >> /etc/heyu/RFxConsole.txt
nohup ./restart.sh >> /etc/heyu/RFxConsole.txt 2>&1 &
#
/usr/bin/tail -n1 /etc/heyu/GasMeter > /tmp/GasMeter               # /tmp is a ram disk on RPi
read date time meter jeecount  < /tmp/GasMeter
echo $meter 0 > /tmp/Min5Gas
#echo "System Startup on `date`"  > /tmp/receive.txt
#
df -h > /tmp/mail_report.log
free -m >> /tmp/mail_report.log
/usr/sbin/ssmtp itaide@googlemail.com << EOF
To: John O'Hare <itaide@googlemail.com>
Date: `date`
From: RasPi1-2 <raspi1-2@it-aide.net>
Subject: Raspberry Pi #1-2 Startup on `date -R`: reboot.sh
Body:
------------------------
`cat /tmp/mail_report.log`
------------------------

EOF
#
sleep 5
/usr/bin/jee 2U190R159T
