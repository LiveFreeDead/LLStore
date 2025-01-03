#!/bin/bash

PACKAGES=gnome-terminal

APT_CMD=$(which apt)
DNF_CMD=$(which dnf)
EMERGE_CMD=$(which emerge)
APK_CMD=$(which apk)
PACMAN_CMD=$(which pacman)
ZYPPER_CMD=$(which zypper)
YUM_CMD=$(which yum)

if [[ ! -z $APT_CMD ]]; then
    sudo $APT_CMD -y install $PACKAGES
elif [[ ! -z $DNF_CMD ]]; then
    sudo $DNF_CMD -y install $PACKAGES
elif [[ ! -z $EMERGE_CMD ]]; then
    sudo $EMERGE_CMD $PACKAGES
elif [[ ! -z $APK_CMD ]]; then
    sudo $APK_CMD add install $PACKAGES
elif [[ ! -z $PACMAN_CMD ]]; then
    yes | sudo $PACMAN_CMD -S $PACKAGES
elif [[ ! -z $ZYPPER_CMD ]]; then
    sudo $ZYPPER_CMD --non-interactive install $PACKAGES
elif [[ ! -z $YUM_CMD ]]; then
    sudo $YUM_CMD -y install $PACKAGES
else
    echo "error can't install package $PACKAGES"
fi

#Run LLStore to install the rest (requires gnome terminal to get sudo)
env GDK_BACKEND=x11 ./llstore -setup


#Notes

#emerge uses non standard package names, will have to manually get their names if supporting gentoo with package manager

# the apk manager is silent by default? you need to add -ask to make it ask?

#elif [[ ! -z $ZYPPER_CMD ]]; then
#    sudo $ZYPPER_CMD --non-interactive install $PACKAGES

#sudo env DEBIAN_FRONTEND=noninteractive sudo apt

#yes | sudo pacman -S firefox

#emerge net-proxy/tinyproxy

