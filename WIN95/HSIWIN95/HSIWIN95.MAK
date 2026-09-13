# Microsoft Visual C++ Generated NMAKE File, Format Version 2.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Static Library" 0x0104

!IF "$(CFG)" == ""
CFG=hsiwin95.lib
!MESSAGE No configuration specified.  Defaulting to hsiwin95.lib.
!ENDIF 

!IF "$(CFG)" != "hsiwin95.lib"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "hsiwin95.mak" CFG="hsiwin95.lib"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "hsiwin95.lib" (based on "Win32 (x86) Static Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

################################################################################
# Begin Project
# PROP Target_Last_Scanned "hsiwin95.lib"
OUTDIR=.\hsiwin95
INTDIR=.\hsiwin95

ALL : $(OUTDIR)/hsiwin95.lib $(OUTDIR)/hsiwin95.bsc

$(OUTDIR) : 
    if not exist $(OUTDIR)/nul mkdir $(OUTDIR)

CPP=cl.exe
BSC32=bscmake.exe
BSC32_SBRS= \
	$(INTDIR)/loopback.sbr \
	$(INTDIR)/scsi.sbr \
	$(INTDIR)/error.sbr \
	$(INTDIR)/monitor.sbr \
	$(INTDIR)/control.sbr \
	$(INTDIR)/ram.sbr \
	$(INTDIR)/aspi.sbr
LIB32=lib.exe
DEF_FLAGS=
DEF_FILE=
LIB32_OBJS= \
	$(INTDIR)/loopback.obj \
	$(INTDIR)/scsi.obj \
	$(INTDIR)/error.obj \
	$(INTDIR)/monitor.obj \
	$(INTDIR)/control.obj \
	$(INTDIR)/ram.obj \
	$(INTDIR)/aspi.obj
# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "hsiwin95"
# PROP BASE Intermediate_Dir "hsiwin95"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "hsiwin95"
# PROP Intermediate_Dir "hsiwin95"
# ADD BASE CPP /nologo /W3 /GX /YX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /FR /c
# ADD CPP /nologo /Zp1 /W3 /GX /Zi /YX /Od /Ob2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /FR /c
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o$(OUTDIR)/"hsiwin95.bsc" 
# ADD BASE LIB32 /NOLOGO
# ADD LIB32 /NOLOGO
LIB32_FLAGS=/NOLOGO /OUT:$(OUTDIR)\"hsiwin95.lib" 
CPP_PROJ=/nologo /Zp1 /W3 /GX /Zi /YX /Od /Ob2 /D "WIN32" /D "NDEBUG" /D\
 "_WINDOWS" /FR$(INTDIR)/ /Fp$(OUTDIR)/"hsiwin95.pch" /Fo$(INTDIR)/\
 /Fd$(OUTDIR)/"hsiwin95.pdb" /c 
CPP_OBJS=.\hsiwin95/

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

$(OUTDIR)/hsiwin95.bsc : $(OUTDIR)  $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

$(OUTDIR)/hsiwin95.lib : $(OUTDIR)  $(DEF_FILE) $(LIB32_OBJS)
    $(LIB32) @<<
  $(LIB32_FLAGS) $(DEF_FLAGS) $(LIB32_OBJS)
<<

################################################################################
# Begin Group "Source Files"

################################################################################
# Begin Source File

SOURCE=\Igneous\Sega\HSIWin\loopback.c
DEP_LOOPB=\
	\Igneous\Sega\HSIWin\SCSIDEFS.H\
	\Igneous\Sega\HSIWin\wnaspi32.h\
	\Igneous\Sega\HSIWin\hsi32win.h\
	\Igneous\Sega\HSIWin\ERROR.H\
	\Igneous\Sega\HSIWin\private.h\
	\Igneous\Sega\HSIWin\scsi.h\
	\Igneous\Sega\HSIWin\game.h
# ADD CPP /Zp1 /Od

$(INTDIR)/loopback.obj :  $(SOURCE)  $(DEP_LOOPB) $(INTDIR)
   $(CPP) /nologo /Zp1 /W3 /GX /Zi /YX /Od /Ob2 /D "WIN32" /D "NDEBUG" /D\
 "_WINDOWS" /FR$(INTDIR)/ /Fp$(OUTDIR)/"hsiwin95.pch" /Fo$(INTDIR)/\
 /Fd$(OUTDIR)/"hsiwin95.pdb" /c  $(SOURCE) 

# End Source File
################################################################################
# Begin Source File

SOURCE=\Igneous\Sega\HSIWin\scsi.c
DEP_SCSI_=\
	\Igneous\Sega\HSIWin\SCSIDEFS.H\
	\Igneous\Sega\HSIWin\wnaspi32.h\
	\Igneous\Sega\HSIWin\scsi.h\
	\Igneous\Sega\HSIWin\hsi32win.h\
	\Igneous\Sega\HSIWin\ERROR.H\
	\Igneous\Sega\HSIWin\private.h
# ADD CPP /Zp1 /Od

$(INTDIR)/scsi.obj :  $(SOURCE)  $(DEP_SCSI_) $(INTDIR)
   $(CPP) /nologo /Zp1 /W3 /GX /Zi /YX /Od /Ob2 /D "WIN32" /D "NDEBUG" /D\
 "_WINDOWS" /FR$(INTDIR)/ /Fp$(OUTDIR)/"hsiwin95.pch" /Fo$(INTDIR)/\
 /Fd$(OUTDIR)/"hsiwin95.pdb" /c  $(SOURCE) 

# End Source File
################################################################################
# Begin Source File

SOURCE=\Igneous\Sega\HSIWin\error.c
DEP_ERROR=\
	\Igneous\Sega\HSIWin\hsi32win.h\
	\Igneous\Sega\HSIWin\ERROR.H\
	\Igneous\Sega\HSIWin\private.h
# ADD CPP /Zp1 /Od

$(INTDIR)/error.obj :  $(SOURCE)  $(DEP_ERROR) $(INTDIR)
   $(CPP) /nologo /Zp1 /W3 /GX /Zi /YX /Od /Ob2 /D "WIN32" /D "NDEBUG" /D\
 "_WINDOWS" /FR$(INTDIR)/ /Fp$(OUTDIR)/"hsiwin95.pch" /Fo$(INTDIR)/\
 /Fd$(OUTDIR)/"hsiwin95.pdb" /c  $(SOURCE) 

# End Source File
################################################################################
# Begin Source File

SOURCE=\Igneous\Sega\HSIWin\monitor.c
DEP_MONIT=\
	\Igneous\Sega\HSIWin\SCSIDEFS.H\
	\Igneous\Sega\HSIWin\wnaspi32.h\
	\Igneous\Sega\HSIWin\scsi.h\
	\Igneous\Sega\HSIWin\hsi32win.h\
	\Igneous\Sega\HSIWin\ERROR.H\
	\Igneous\Sega\HSIWin\private.h\
	\Igneous\Sega\HSIWin\game.h\
	\Igneous\Sega\HSIWin\hsi32mon.h
# ADD CPP /Zp1 /Od

$(INTDIR)/monitor.obj :  $(SOURCE)  $(DEP_MONIT) $(INTDIR)
   $(CPP) /nologo /Zp1 /W3 /GX /Zi /YX /Od /Ob2 /D "WIN32" /D "NDEBUG" /D\
 "_WINDOWS" /FR$(INTDIR)/ /Fp$(OUTDIR)/"hsiwin95.pch" /Fo$(INTDIR)/\
 /Fd$(OUTDIR)/"hsiwin95.pdb" /c  $(SOURCE) 

# End Source File
################################################################################
# Begin Source File

SOURCE=\Igneous\Sega\HSIWin\control.c
DEP_CONTR=\
	\Igneous\Sega\HSIWin\SCSIDEFS.H\
	\Igneous\Sega\HSIWin\wnaspi32.h\
	\Igneous\Sega\HSIWin\hsi32win.h\
	\Igneous\Sega\HSIWin\ERROR.H\
	\Igneous\Sega\HSIWin\private.h\
	\Igneous\Sega\HSIWin\scsi.h
# ADD CPP /Zp1 /Od

$(INTDIR)/control.obj :  $(SOURCE)  $(DEP_CONTR) $(INTDIR)
   $(CPP) /nologo /Zp1 /W3 /GX /Zi /YX /Od /Ob2 /D "WIN32" /D "NDEBUG" /D\
 "_WINDOWS" /FR$(INTDIR)/ /Fp$(OUTDIR)/"hsiwin95.pch" /Fo$(INTDIR)/\
 /Fd$(OUTDIR)/"hsiwin95.pdb" /c  $(SOURCE) 

# End Source File
################################################################################
# Begin Source File

SOURCE=\Igneous\Sega\HSIWin\ram.c
DEP_RAM_C=\
	\Igneous\Sega\HSIWin\SCSIDEFS.H\
	\Igneous\Sega\HSIWin\wnaspi32.h\
	\Igneous\Sega\HSIWin\hsi32win.h\
	\Igneous\Sega\HSIWin\ERROR.H\
	\Igneous\Sega\HSIWin\private.h\
	\Igneous\Sega\HSIWin\scsi.h
# ADD CPP /Zp1 /Od

$(INTDIR)/ram.obj :  $(SOURCE)  $(DEP_RAM_C) $(INTDIR)
   $(CPP) /nologo /Zp1 /W3 /GX /Zi /YX /Od /Ob2 /D "WIN32" /D "NDEBUG" /D\
 "_WINDOWS" /FR$(INTDIR)/ /Fp$(OUTDIR)/"hsiwin95.pch" /Fo$(INTDIR)/\
 /Fd$(OUTDIR)/"hsiwin95.pdb" /c  $(SOURCE) 

# End Source File
################################################################################
# Begin Source File

SOURCE=\Igneous\Sega\HSIWin\aspi.c
DEP_ASPI_=\
	\Igneous\Sega\HSIWin\SCSIDEFS.H\
	\Igneous\Sega\HSIWin\wnaspi32.h\
	\Igneous\Sega\HSIWin\hsi32win.h\
	\Igneous\Sega\HSIWin\ERROR.H\
	\Igneous\Sega\HSIWin\private.h
# ADD CPP /Zp1 /Od

$(INTDIR)/aspi.obj :  $(SOURCE)  $(DEP_ASPI_) $(INTDIR)
   $(CPP) /nologo /Zp1 /W3 /GX /Zi /YX /Od /Ob2 /D "WIN32" /D "NDEBUG" /D\
 "_WINDOWS" /FR$(INTDIR)/ /Fp$(OUTDIR)/"hsiwin95.pch" /Fo$(INTDIR)/\
 /Fd$(OUTDIR)/"hsiwin95.pdb" /c  $(SOURCE) 

# End Source File
# End Group
# End Project
################################################################################
