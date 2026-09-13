@echo off

IF NOT EXIST %SEGALIBAWK%\*.awk GOTO noscript

IF "%1"=="" GOTO help

IF EXIST %TEMP%\gasm?.tmp del %TEMP%\gasm?.tmp

awk -f %SEGALIBAWK%\comment.awk %1 > %TEMP%\gasm0.tmp
IF ERRORLEVEL 1 GOTO error
awk -f %SEGALIBAWK%\keyword.awk %TEMP%\gasm0.tmp > %TEMP%\gasm1.tmp
IF ERRORLEVEL 1 GOTO error
awk -f %SEGALIBAWK%\section.awk %TEMP%\gasm1.tmp > %TEMP%\gasm2.tmp
IF ERRORLEVEL 1 GOTO error
gasp -u %TEMP%\gasm2.tmp > %TEMP%\gasm3.tmp
IF ERRORLEVEL 1 GOTO error
awk -f %SEGALIBAWK%\gasp.awk %TEMP%\gasm3.tmp > %TEMP%\gasm4.tmp
IF ERRORLEVEL 1 GOTO error
gasp -u %TEMP%\gasm4.tmp > %TEMP%\gasm5.tmp
IF ERRORLEVEL 1 GOTO error
awk -f %SEGALIBAWK%\pool.awk %TEMP%\gasm5.tmp > %TEMP%\gasm6.tmp
IF ERRORLEVEL 1 GOTO error
as %TEMP%\gasm6.tmp %2 %3 %4 %5 %6 %7 %8 %9
IF ERRORLEVEL 1 GOTO error
GOTO end

:noscript
ECHO ƒXƒNƒŠƒvƒgƒtƒ@ƒCƒ‹‚Ì‚ ‚éƒfƒBƒŒƒNƒgƒŠ‚ðŠÂ‹«•Ï” SEGALIBAWK ‚ÉŽw’è‚µ‚Ä‚­‚¾‚³‚¢.
ECHO\
GOTO end

:help
ECHO"C:\> gasm source-file [as-options][30m"[m
ECHO\
ECHO [as-options]
ECHO     as ‚É‘Î‚·‚éƒIƒvƒVƒ‡ƒ“
ECHO\
ECHO Žg—p‚·‚éŠÂ‹«•Ï”
ECHO   SEGALIBAWK  awk ‚ÌƒXƒNƒŠƒvƒgƒtƒ@ƒCƒ‹‚Ì‚ ‚éƒfƒBƒŒƒNƒgƒŠ‚ðŽw’è‚·‚é
ECHO               Žw’è‚Ì‚È‚¢‚Æ‚«‚Íƒ‹[ƒgƒfƒBƒŒƒNƒgƒŠ‚ðŽw’è‚³‚ê‚½‚à‚Ì‚Æ‚Ý‚È‚µ‚Ü‚·
ECHO   TEMP        ƒeƒ“ƒ|ƒ‰ƒŠƒtƒ@ƒCƒ‹‚ðì¬‚·‚éƒfƒBƒŒƒNƒgƒŠ‚ðŽw’è‚·‚é
ECHO               Žw’è‚Ì‚È‚¢‚Æ‚«‚Íƒ‹[ƒgƒfƒBƒŒƒNƒgƒŠ‚ðŽw’è‚³‚ê‚½‚à‚Ì‚Æ‚Ý‚È‚µ‚Ü‚·
ECHO\
GOTO end

:error
echo error!!
:end
