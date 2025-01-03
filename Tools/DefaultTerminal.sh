#!/bin/bash

terms=(gnome-terminal konsole x-terminal-emulator xterm xfce4-terminal)
for t in ${terms[*]}
do
    if [ $(command -v $t) ]
    then
        detected_term=$t
        break
    fi
done
echo $detected_term
