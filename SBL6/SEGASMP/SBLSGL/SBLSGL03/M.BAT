@echo off
echo ---------------------------------------------------------------------------
echo   main.bat -- PC 用 サンプル作成コマンドファイル
echo   Copyright(c) 1994 SEGA
echo   Written by H.E on 1994-02-15 Ver.0.80
echo   Updated by K.M on 1994-05-10 Ver.0.80
echo ---------------------------------------------------------------------------
rem set SHC_LIB=..\..\..\SH\bin
rem set SHC_INC=..\..\..\SH\INCLUDE
rem set SHC_TMP=..\..\..\sh\bin

del sblsgl03.abs
del *.obj
shc -sub=..\mk.cfg sblsgl03.c
shc -sub=..\mk.cfg textur.c
lnk /sub=main.sub
rof2bin sblsgl03.abs
rem end of file
