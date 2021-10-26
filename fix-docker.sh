#!/bin/bash

################################################################
#################### Fix gcc version ###########################
################################################################

# This should really go into their dockerfile somewhere, but don't know where to put it...
echo -ne '\n' | add-apt-repository ppa:ubuntu-toolchain-r/test
apt-get update
apt-get install gcc-9 g++-9 -y 

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 7
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 7
update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-7 7
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9
update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-9 9


# Run the pip install without root permissions (if user is doing this)
if [[ ! -z "$SUDO_USER" ]]
then    
    sudo -u $SUDO_USER pip3 install fastcov astor
else
    pip3 install fastcov astor
fi

# Put our maps in the right spot...
./add-maps.sh
