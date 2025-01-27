#!/bin/bash

IS_GNOMETERMINAL=$(which gnome-terminal)

if [[ -z $IS_GNOMETERMINAL ]]; then

PACKAGES=gnome-terminal

APT_CMD=$(which apt 2>/dev/null)
DNF_CMD=$(which dnf 2>/dev/null)
EMERGE_CMD=$(which emerge 2>/dev/null)
EOPKG_CMD=$(which eopkg 2>/dev/null)
APK_CMD=$(which apk 2>/dev/null)
PACMAN_CMD=$(which pacman 2>/dev/null)
ZYPPER_CMD=$(which zypper 2>/dev/null)
YUM_CMD=$(which yum 2>/dev/null)

if [[ ! -z $APT_CMD ]]; then
    sudo $APT_CMD -y install $PACKAGES
elif [[ ! -z $DNF_CMD ]]; then
    sudo $DNF_CMD -y install $PACKAGES
elif [[ ! -z $EMERGE_CMD ]]; then
    sudo $EMERGE_CMD $PACKAGES
elif [[ ! -z $EOPKG_CMD ]]; then
    sudo $EOPKG_CMD -y install $*
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

fi  #Top gnome check



#Run LLStore to install the rest (requires gnome terminal to get sudo)
env GDK_BACKEND=x11 ./llstore -setup



#Notes

#emerge uses non standard package names, will have to manually get their names if supporting gentoo with package manager

# the apk manager is silent by default? you need to add -ask to make it ask?

#elif [[ ! -z $ZYPPER_CMD ]]; then
#    sudo $ZYPPER_CMD --non-interactive install $PACKAGES

#sudo env DEBIAN_FRONTEND=noninteractive sudo apt

#emerge net-proxy/tinyproxy

