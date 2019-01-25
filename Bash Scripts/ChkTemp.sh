#!/bin/bash
/usr/bin/tail -n1 /etc/heyu/JeeTempDecoder.dat > /tmp/JeeTempDecoder.dat
read date time node command x y type seq goodFloor badFloor failNoiseCount rxRssi temperature voltage < /tmp/JeeTempDecoder.dat
if [ "$temperature" -le "400" ]; then
let "t = $temperature / 100"
/usr/sbin/ssmtp itaide@googlemail.com << EOF
To: John O'Hare <itaide@googlemail.com>
#From: RasPi1-2 <raspi1-2@it-aide.net>
Date: `date`
Subject: RasPi1-2: Sandhurst Temperature is < $t°C on `date -R`
Body: 
/etc/heyu/JeeGasCounterDecoder.dat
----------------------------------
`tail /etc/heyu/JeeTempDecoder.dat`
----------------------------------
/etc/heyu/JeeRoomNodeDecoder.dat
----------------------------------
`tail /etc/heyu/JeeRoomNodeDecoder.dat`
----------------------------------

EOF
fi
