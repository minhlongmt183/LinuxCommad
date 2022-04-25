#!/bin/bash
sudo apt-get -y update
sudo apt-get -y install python3 python3-pip python3-dev git libssl-dev libffi-dev build-essential
python3 -m pip3 install --upgrade pip3
python3 -m pip install --upgrade pwntools
