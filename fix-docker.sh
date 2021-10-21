#!/bin/bash

################################################################
#################### Fix gcc version ###########################
################################################################
echo -ne '\n' | add-apt-repository ppa:ubuntu-toolchain-r/test
apt update
apt install gcc-9 g++-9 -y 

# Run the pip install without root permissions
sudo -u $SUDO_USER pip3 install fastcov astor

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 7
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 7
update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-7 7
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9
update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-9 9
