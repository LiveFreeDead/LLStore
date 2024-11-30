#!/bin/bash

terms=(gnome-terminal xfce4-terminal konsole x-terminal-emulator xterm)
for t in ${terms[*]}
do
    if [ $(command -v $t) ]
    then
        detected_term=$t
        break
    fi
done
echo $detected_term
