#!/bin/bash

cp ntripcaster.conf /usr/local/ntripcaster/

cp *.service /etc/systemd/system
systemctl daemon-reload



