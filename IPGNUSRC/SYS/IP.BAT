gasm sys_id.src  -o sys_id.o
gcc -c -g -O0 -Wall -DMODEL_S -I/gccsh/include -I../../segalib/lib/include -o smpsys.o smpsys.c
ld -o smpsys.sre -Map smpsys.map -T smpsys.lnk sys_id.o ../../segalib/lib/sys_sec.o ../../segalib/lib/sys_arej.o ../../segalib/lib/sys_init.o smpsys.o
sretobin smpsys.sre ip.bin
