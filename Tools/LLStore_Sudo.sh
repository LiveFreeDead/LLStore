#!/bin/bash

echo "Sudo Script Started"

#Remove any existing scripts so no leftovers interfere
rm -f /tmp/LLScript_Sudo.sh
rm -f /tmp/LLSudoDone

#echo "Unlock" > /tmp/LLSudo
rm -f /tmp/LLSudo

#do loop here and constant wait to run a shell script and delete it once it's ran
while [ ! -f /tmp/LLSudoDone ]
do
    if [ -f /tmp/LLScript_Sudo.sh ]; then
        chown 775 /tmp/LLScript_Sudo.sh
       /tmp/LLScript_Sudo.sh ; rm -f /tmp/LLScript_Sudo.sh
    fi
    #0 should give it a short delay, but try to support floating point sleep commands in compatible Linux versions should free up more cycles.
	sleep 0 ; sleep 0.1 2>/dev/null

    #Remove Handshake File, quicker to just delete it than to see if exists
    rm -f /tmp/LLSudoHandShake

done

#Clean up
rm -f /tmp/LLSudoDone

echo "Sudo Script Ended"
