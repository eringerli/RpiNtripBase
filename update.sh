#!/bin/bash

cp ntripcaster.conf /usr/local/ntripcaster/
cp ntripcaster.logrotate /usr/local/ntripcaster/

cp *.service /etc/systemd/system
systemctl daemon-reload

systemctl try-restart ntripcaster.service
systemctl try-restart str2str.service
systemctl try-restart logrotate-ntripcaster.service
