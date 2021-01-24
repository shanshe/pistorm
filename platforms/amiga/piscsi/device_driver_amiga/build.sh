#m68k-amigaos-gcc piscsi-amiga.c -ramiga-dev -noixemul -fbaserel -O2 -o pi-scsi.device -ldebug -lamiga -m68020
m68k-amigaos-gcc -m68020 -O2 -o pi-scsi.device -ramiga-dev -noixemul -fbaserel piscsi-amiga.c -ldebug -lamiga
