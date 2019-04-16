#!/bin/bash

cp ntripcaster.conf /usr/local/ntripcaster/conf/

cp *.service /etc/systemd/system
systemctl daemon-reload



