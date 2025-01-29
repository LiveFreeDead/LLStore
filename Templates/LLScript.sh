#!/bin/bash

#Get Best Terminal
terms=(gnome-terminal konsole x-terminal-emulator xterm xfce4-terminal)
for t in ${terms[*]}
do
    if [ $(command -v $t) ]
    then
        OSTERM=$t
        break
    fi
done

#Get Package Manager
APT_CMD=$(which apt 2>/dev/null)
DNF_CMD=$(which dnf 2>/dev/null)
EMERGE_CMD=$(which emerge 2>/dev/null)
EOPKG_CMD=$(which eopkg 2>/dev/null)
APK_CMD=$(which apk 2>/dev/null)
PACMAN_CMD=$(which pacman 2>/dev/null)
ZYPPER_CMD=$(which zypper 2>/dev/null)
YUM_CMD=$(which yum 2>/dev/null)


#Get Desktop Environment to do tasks
echo "Terminal Used: $OSTERM"
echo "Desktop Environment: $XDG_SESSION_DESKTOP"

#Use below sections to put update/upgrade repository or add PPA or repo's
PM=""
if [[ ! -z $DNF_CMD ]]; then #dnf
    PM=dnf
    echo "Package Manager: dnf"
elif [[ ! -z $APT_CMD ]]; then #apt
    echo "Package Manager: apt"
    PM=apt
    #sudo apt -qq update -y 
    ##sudo apt upgrade -y #Only use to apply updates, not required for repo's
elif [[ ! -z $EMERGE_CMD ]]; then #emerge
    PM=emerge
    echo "Package Manager: emerge"
elif [[ ! -z $EOPKG_CMD ]]; then #eopkg
    PM=eopkg
    echo "Package Manager: eopkg"
elif [[ ! -z $APK_CMD ]]; then #apk
    PM=apk
    echo "Package Manager: apk"
elif [[ ! -z $PACMAN_CMD ]]; then #pacman
    PM=pacman
    echo "Package Manager: pacman"
elif [[ ! -z $ZYPPER_CMD ]]; then #zypper
    PM=zypper
    echo "Package Manager: zypper"
elif [[ ! -z $YUM_CMD ]]; then #yum
    PM=yum
    echo "Package Manager: yum"
else
    echo "Package Manager: none configured"
fi


#Get OS ID and do things depending on which one
. /etc/os-release

echo "OS ID: $ID"

case $ID in
  linuxmint|ubuntu) 
    ;;

  debian|pop)
    ;;

  fedora) 
    ;;

  opensuse-tumbleweed) 
    ;;

  arch|endeavouros)
    ;;

  solus)
    ;;

  *) 
    echo "This is an unknown distribution."
      ;;
esac

#Do tasks for each Desktop Environment
case $XDG_SESSION_DESKTOP in

  cinnamon)
    ;;

  gnome|ubuntu)
    ;;
  
  kde|KDE)
    ;;

  lxde)
    ;;

  mate)
    ;;
  
  unity)
    ;;

  xfce)
    ;;

  cosmic|pop)
    ;;

  budgie-desktop)
    ;;

  LXQt)
    ;;

  *)
    echo "This is an unknown desktop environment."
    ;;
esac


#FlatPak
#Add "org.name.thing" to end of line in quote below and unremark to install a Flatpak
#$OSTERM -e "flatpak install --user -y --noninteractive flathub "




