#!/usr/bin/env sh
#
# The script deletes current directory and launchers
# base version 01.12.2020 by Хрюнделёк
# version 02.02.2025 by Glenn Chugg
# https://www.lastos.org

# Initial set
dir="$(dirname "$(readlink -f "$0")")"
app="$(basename "$dir")"

#Remove LLStore folder name Suffix etc
app=$(echo $app | sed 's,\., ,g')
app=$(echo $app | sed 's,\_, ,g')
app=$(echo $app | sed 's,\LLGame, ,g')
app=$(echo $app | sed 's,\LLApp, ,g')
app=$(echo $app | xargs ) #Trim

#Make appdesktop the name of the file (Spaces converted back to .)
appdesktop=$(echo $app | sed 's,\ ,.,g')

# User environment launchers
if [ -z "$XDG_CONFIG_HOME" ]; then
	XDG_CONFIG_HOME=$HOME/.config
fi
# shellcheck source=/dev/null
. "$XDG_CONFIG_HOME"/user-dirs.dirs 2>/dev/null

if [ -z "$XDG_DATA_HOME" ]; then
	XDG_DATA_HOME=$HOME/.local/share
fi

if [ -z "$XDG_DESKTOP_DIR" ]; then
	XDG_DESKTOP_DIR=$HOME/Desktop
fi

#Check it's not a major directory (don't want to accidently run this script from the wrong path

echo "Testing removal of: $dir"

if [ "$app" = "Tools" ]; then #Because I keep this in my Tools folder, I'll test for that too
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "$HOME" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "$XDG_DESKTOP_DIR" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "$XDG_DATA_HOME" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "$XDG_CONFIG_HOME" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/etc" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/home" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/LastOS" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/opt" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/proc" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/srv" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/sys" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/tmp" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/usr" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/var" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/bin" ]; then
    echo "Protected Folder"
    exit 1
fi

if [ "$dir" = "/sbin" ]; then
    echo "Protected Folder"
    exit 1
fi

#If any above are true then it quits, Otherwise it will ask below to remove folder and links
#echo $appdesktop
#exit 1

desklauncher=$XDG_DESKTOP_DIR/$appdesktop.desktop
menudir=$XDG_DATA_HOME/applications
menulauncher=$menudir/$appdesktop.desktop

# Localization
if (locale | grep -e 'ru_RU' >/dev/null); then
	title="Удаление"
	msg="Удалить"
	msg2="Удаляется"
	msg3="Готово."
	canc="Отмена."
else
	title="Uninstall"
	msg="Do you want to uninstall"
	msg2="Uninstalling"
	msg3="Done."
	canc="Canceled."
fi

# Prompt colors
red="\033[1;31m"
green="\033[1;32m"
reset="\033[0m"

# Check zenity & kdialog, otherwise run in the terminal
if command -v zenity >/dev/null; then
	if zenity --question --title="$title $app" --text="$msg $app?" \
--no-wrap >/dev/null 2>&1; then
		rm -f "$desklauncher" "$menulauncher"
		cd "$dir"/.. || exit
		rm -rf "$dir" | zenity --progress --title="$title $app" \
--text="$msg2 $app..." --width=300 --pulsate --no-cancel --auto-close \
>/dev/null 2>&1
	else
		exit
	fi
	zenity --info --title="$title $app" --text="$msg3" --no-wrap \
>/dev/null 2>&1
	exit
elif command -v kdialog >/dev/null; then
	if kdialog --yesno "$msg $app?" --title="$title $app" >/dev/null \
2>&1; then
		rm -f "$desklauncher" "$menulauncher"
		cd "$dir"/.. || exit
		rm -rf "$dir"
	else
		exit
	fi
	kdialog --msgbox "$msg3" --title="$title $app" >/dev/null 2>&1
	exit
else
	clear
	printf "\n%s  $msg $app? (y)es/(n)o:\n\n"
	read -r answer
	case "$answer" in
		[y])
			printf "\n%s$msg2 $app...\n"
			rm -f "$desklauncher" "$menulauncher"
			cd "$dir"/.. || exit
			rm -rf "$dir"
			printf "\n%s${green}$msg3${reset}\n\n"
			;;
		*)
			printf "\n%s  ${red}$canc${reset}\n\n"
			exit
	esac
fi
exit 0
