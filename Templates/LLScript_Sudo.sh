#!/bin/bash

#Functions
inst () {
APT_CMD=$(which apt 2>/dev/null)
DNF_CMD=$(which dnf 2>/dev/null)
EMERGE_CMD=$(which emerge 2>/dev/null)
EOPKG_CMD=$(which eopkg 2>/dev/null)
APK_CMD=$(which apk 2>/dev/null)
PACMAN_CMD=$(which pacman 2>/dev/null)
ZYPPER_CMD=$(which zypper 2>/dev/null)
YUM_CMD=$(which yum 2>/dev/null)

if [[ ! -z $DNF_CMD ]]; then
    sudo $DNF_CMD -y install $*
elif [[ ! -z $APT_CMD ]]; then
    sudo $APT_CMD -y install $*
elif [[ ! -z $EMERGE_CMD ]]; then
    sudo $EMERGE_CMD $PACKAGES
elif [[ ! -z $EOPKG_CMD ]]; then
    sudo $EOPKG_CMD -y install $*
elif [[ ! -z $APK_CMD ]]; then
    sudo $APK_CMD add install $*
elif [[ ! -z $PACMAN_CMD ]]; then
    #yes | sudo $PACMAN_CMD -S $*
    # Syu gets dependancies etc
    yes | sudo $PACMAN_CMD -Syu $*
elif [[ ! -z $ZYPPER_CMD ]]; then
    sudo $ZYPPER_CMD --non-interactive install $*
elif [[ ! -z $YUM_CMD ]]; then
    sudo $YUM_CMD -y install $*
else
    echo "error can't install package $*"
fi
}


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
    #sudo apt upgrade -y
elif [[ ! -z $EMERGE_CMD ]]; then #emerge
    PM=emerge
    echo "Package Manager: emerge"
elif [[ ! -z $EOPKG_CMD ]]; then
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
    #zypper refresh
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
    #sudo mkdir -pm755 /etc/apt/keyrings
    #sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
    #sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
    #sudo apt -qq update -y && sudo apt upgrade -y
    ;;

  debian|pop)
    #sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
    #sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
    #sudo apt update
    ;;

  fedora)
    #yes | sudo dnf config-manager addrepo --from-repofile=https://dl.winehq.org/wine-builds/fedora/41/winehq.repo
    #yes | sudo dnf upgrade
    ;;

  opensuse-tumbleweed) 
    #zypper --non-interactive addrepo https://download.opensuse.org/repositories/Emulators:Wine/openSUSE_Tumbleweed/Emulators:Wine.repo
    #zypper refresh
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


#Install Apps - using Inst function to work on many Distro's and if packages available on it's repositories.
#inst numlockx xclip


#FlatPak System Wide, user should be done in non Sudo script
#Add "org.name.thing" to end of line in quote below and unremark to install a Flatpak
#$OSTERM -e "flatpak install --system -y --noninteractive flathub "


