#!/bin/bash
#
# This script is designed to install the Android SDK, NDK, and Eclipse in
# Linux Mint 11 and make it easier for people that want to develop for
# Android using Linux.
# Script written by @ArchDukeDoug with special thanks to @BoneyNicole,
# @tabbwabb, and @animedbz16 for putting up with me and proofreading and/or
# testing the script.
# I can be reached at dougw@uab.edu, twitter, or linuxrandomly.blogspot.com
# Script version: 1.0.5
# Changelog: 1.0.5 - Fixed the Android SDK search parameters to fit the new
# naming scheme on http://developer.android.com/sdk

# Edit by christoph Langner http://linuxundich.de
# Removed installation von Android NDK and Eclipse

# Edit by Trust@FHH http://trust.f4.hs-hannover.de

i=$(cat /proc/$PPID/cmdline)
if [[ $UID != 0 ]]; then
    echo "Please type sudo $0 $*to use this."
    exit 1
fi

apt-get update

#Download and install the Android SDK
if [ ! -d "/usr/local/android-sdk" ]; then
	for a in $( wget -qO- http://developer.android.com/sdk/index.html | egrep -o "http://dl.google.com[^\"']*linux.tgz" ); do 
		wget $a && tar --wildcards --no-anchored -xvzf android-sdk_*-linux.tgz; mv android-sdk-linux /usr/local/android-sdk; chmod 777 -R /usr/local/android-sdk; rm android-sdk_*-linux.tgz;
	done
else
     echo "Android SDK already installed to /usr/local/android-sdk.  Skipping."
fi

d=ia32-libs

#Determine if there is a 32 or 64-bit operating system installed and then install ia32-libs if necessary.

if [[ `getconf LONG_BIT` = "64" ]]; 

then
    echo "64-bit operating system detected.  Checking to see if $d is installed."

    if [[ $(dpkg-query -f'${Status}' --show $d 2>/dev/null) = *\ installed ]]; then
    	echo "$d already installed."
    else
        echo "Installing now..."
    	apt-get --force-yes -y install $d
    fi
else
	echo "32-bit operating system detected.  Skipping."
fi

#Check if the ADB environment is set up.

if grep -q /usr/local/android-sdk/platform-tools /etc/bash.bashrc; 
then
    echo "ADB environment already set up"
else
    echo "export PATH=$PATH:/usr/local/android-sdk/platform-tools" >> /etc/bash.bashrc
fi

#Check if the ddms symlink is set up.

if [ -f /bin/ddms ] 
then
    rm /bin/ddms; ln -s /usr/local/android-sdk/tools/ddms /bin/ddms
else
    ln -s /usr/local/android-sdk/tools/ddms /bin/ddms
fi

#Check if ADB is already installed
if [ ! -f "/usr/local/android-sdk/platform-tools/adb" ];
then
nohup /usr/local/android-sdk/tools/android update sdk > /dev/null 2>&1 &
else
echo "Android Debug Bridge already detected."
fi
exit 0