@echo off

IF "%1"=="" GOTO help

IF EXIST %TEMP%\gasm?.tmp del %TEMP%\gasm?.tmp

awk -f comment.awk %1 > %TEMP%\gasm0.tmp
IF ERRORLEVEL 1 GOTO end
awk -f keyword.awk %TEMP%\gasm0.tmp > %TEMP%\gasm1.tmp
IF ERRORLEVEL 1 GOTO end
awk -f section.awk %TEMP%\gasm1.tmp > %TEMP%\gasm2.tmp
IF ERRORLEVEL 1 GOTO end
gasp -u %TEMP%\gasm2.tmp > %TEMP%\gasm3.tmp
IF ERRORLEVEL 1 GOTO end
awk -f gasp.awk %TEMP%\gasm3.tmp > %TEMP%\gasm4.tmp
IF ERRORLEVEL 1 GOTO end
gasp -u %TEMP%\gasm4.tmp > %TEMP%\gasm5.tmp
IF ERRORLEVEL 1 GOTO end
awk -f pool.awk %TEMP%\gasm5.tmp > %TEMP%\gasm6.tmp
IF ERRORLEVEL 1 GOTO end
as %TEMP%\gasm6.tmp %2 %3 %4 %5 %6 %7 %8 %9
IF ERRORLEVEL 1 GOTO end
GOTO end


:help
ECHO"C:\> gasm source-file [as-options]"
ECHO\
GOTO end

:end
