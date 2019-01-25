#!/bin/bash
IP=$(dig sandhurst.strangled.net +short)
sudo /home/john/fbtunnel 5 mysecret 192.168.250.22 $IP
