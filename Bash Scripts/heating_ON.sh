#!/bin/bash
/usr/bin/jee 17,11p
sleep 180
/usr/sbin/ssmtp itaide@googlemail.com << EOF
To: John O'Hare <itaide@googlemail.com>
Date: `date`
From: RasPi1-2 <raspi1-2@it-aide.net>
Subject: Sandhurst Heating On #1-2 on `date -R`
Body:
------------------------
`tail /etc/heyu/JeeCentralMonitor.dat`
------------------------
`tail /etc/heyu/RFxConsole.txt`
------------------------
`tail /etc/heyu/Posted.txt`
------------------------

EOF

##
