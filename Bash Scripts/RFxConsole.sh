#!/bin/bash
#
cd /etc/heyu
stty -F /dev/JeeLink -hupcl
./RFxConsole >> /etc/heyu/RFxConsole.txt 2>&1
#
/usr/sbin/ssmtp itaide@googlemail.com << EOF
To: John O'Hare <itaide@googlemail.com>
Date: `date`
From: RasPi1-2 <raspi1-2@it-aide.net>
Subject: Raspberry Pi #1-2 RFxConsole exited on `date -R`
Body:
------------------------
`tail /etc/heyu/RFxConsole.txt`
------------------------
`ps aux`
------------------------

EOF
/etc/heyu/restart.sh &
#
