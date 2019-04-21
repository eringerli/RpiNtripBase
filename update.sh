#!/bin/bash

cp ntripcaster.conf /usr/local/ntripcaster/
cp ntripcaster.logrotate /usr/local/ntripcaster/
cp m8t_base.cmd /usr/local/ntripcaster/

cp *.service *.timer /etc/systemd/system
systemctl daemon-reload

systemctl try-restart ntripcaster.service
systemctl try-restart str2str.service
systemctl try-restart str2str-M8T.service
systemctl try-restart logrotate-ntripcaster.timer

