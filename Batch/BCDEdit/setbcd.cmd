rem bcdedit /store \boot\bcd /set {09dc34d7-07bf-11e1-ac50-78dd08aeae75} DEVICE ramdisk=[boot]\sources\boot2.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}
rem bcdedit /store \boot\bcd /set {09dc34d7-07bf-11e1-ac50-78dd08aeae75} OSDEVICE ramdisk=[boot]\sources\boot2.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}
bcdedit /store \boot\bcd /set {4fa55a80-07c8-11e1-bb83-78dd08aeae75} DEVICE ramdisk=[boot]\NewStuff\boot.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}
bcdedit /store \boot\bcd /set {4fa55a80-07c8-11e1-bb83-78dd08aeae75} OSDEVICE ramdisk=[boot]\NewStuff\boot.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}
