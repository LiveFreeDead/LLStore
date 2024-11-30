#!/bin/bash

#Sets to 240DPI in winecfg, default is 0x60, 2k screen uses 0x90, 4k screen uses 0xF0 - C0 = 192, looks better on 4k IMO
#wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d 0x60 /f
#wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d 0x90 /f
#wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d 0x60 /f

rm -f "/tmp/LLStore.reg"
wine reg export "HKEY_CURRENT_USER\Control Panel\Desktop" "/tmp/LLStore.reg" /Y



