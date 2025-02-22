# install for Linux  
---  
```bash
#!/bin/bash
sudo apt update -y
sudo apt install -y wget
sudo apt install -y curl

## pwntools
sudo apt-get -y install python3 python3-pip python3-dev git libssl-dev libffi-dev build-essential
python3 -m pip3 install --upgrade pip3
python3 -m pip install --upgrade pwntools

## gdb
sudo apt-get -y install gdb
cd ~ && git clone https://github.com/apogiatzis/gdb-peda-pwndbg-gef.git
cd ~/gdb-peda-pwndbg-gef
./install.sh

## sublime-text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get -y update
sudo apt-get install -y sublime-text

## go install
wget -q -O - https://git.io/vQhTU |  bash -s -- --version 1.24.0 >/dev/null 2>&1

# install ptdm
https://github.com/projectdiscovery/pdtm

# more swap on server
fallocate -l 8G /swap && chmod 600 /swap && mkswap /swap && swapon /swap
```
