#!/bin/bash

mkdir -p /usr/local/ntripcaster/conf/ 

cp ntripcaster.conf /usr/local/ntripcaster/
cp ntripcaster.logrotate /usr/local/ntripcaster/
if [[ -f "sourcetable.dat" ]]; then
  cp sourcetable.dat /usr/local/ntripcaster/conf/
fi

cp m8t_base.cmd /usr/local/ntripcaster/
cp rtcmadd1008.py /usr/local/bin/

cp *.service *.timer /etc/systemd/system
systemctl daemon-reload

systemctl try-restart ntripcaster.service
systemctl try-restart str2str.service
systemctl try-restart str2str-M8T.service
systemctl try-restart str2str-injectrtcm1008.service
systemctl try-restart str2str-remoteCaster.service
systemctl try-restart logrotate-ntripcaster.timer
systemctl try-restart ntripserver.service
systemctl try-restart ntripserver-remoteCaster.service
