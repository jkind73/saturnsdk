/*
 //    error.c -
 //
 //      contains code to handle error reporting and text translation from
 //      an EC or error code to text.
 //    
 //
 //    NOTES
 //        
 //    REFERENCES
 //        
 //    LANGUAGE
 //        ANSI C
 //
 //    LIB      This code comprises the HSI library.
 //        
 //    SEE ALSO The include files (hsi.h) for application info.
 //
 //   These functions are defined here:
 //
 //      EC    HSI_GetLastError(void);
 //      char *HSI_GetErrorText(EC);
 //      void  HSI_SetTimeOutValue(DWORD  val);
 //      DWORD HSI_GetTimeOutValue(void);
 //
 //   These globals are declared here:
 //
 //      ErrorMap structure 
 //        
 //    MODS
 //      Written by the Igneous Group under agreement with Sega Of America.
 //        The Igneous Group
 //        1744 Foster Court
 //        Santa Cruz, CA 95062
 //        408 475 8194 voice
 //        408 475 8193 fax
 //        igneous@netcom.com
 //
 //        Copyright (C) 1994, Sega Of America, Inc.
 //        All Rights Reserved
 //
 //        GBC   27 Jan 94   Initial Creation
 //        GBC   12 May 94   Built for 32 bit operation...
 //        GBC   15 Aug 95   Added Get and Set Timeout functions.
*/


#include    <windows.h>

#include    "hsi32win.h"
#include    "error.h"
#include    "private.h"

struct {
   EC tag;
   char *text;
} ErrorMap[] = {
   {(EC) 0,                                     "No error."},
   {MakeEC(err_LIB,  err_NOASPI),               "No ASPI driver installed!"},
   {MakeEC(err_LIB,  err_ChannelNotAlloc),      "Channel is not allocated."},
   {MakeEC(err_LIB,  err_NoChannelsAvail),      "No channels available."},
   {MakeEC(err_LIB,  err_NoCartdevFound),       "No CARTDEV device found."},
   {MakeEC(err_LIB,  err_LoopBackFailed),       "Loop back monitor diagnostic failed."},
   {MakeEC(err_LIB,  err_BadPointer),           "Pointer Invalid, not in lower 1Mb."},
   {MakeEC(err_LIB,  err_ProtMode),             "Error in protected to real mode switch."},
   {MakeEC(err_LIB,  err_GameNotReady),         "Game is not responding."},
   {MakeEC(err_LIB,  err_MemoryAllocFail),      "Memory allocation failed."},
   {MakeEC(err_LIB,  err_CreateEvent),          "Unable to create the ASPI completion event."},
   {MakeEC(err_LIB,  err_ThreadTerminated),     "Owning thread terminated."},
   {MakeEC(err_SCSI, err_ID_INVALID),           "Invalid SCSI ID."},
   {MakeEC(err_SCSI, err_NOTARGET),             "No Target device present."},
   {MakeEC(err_SCSI, err_REQ_ABORTED),          "ASPI - SCSI request aborted."},
   {MakeEC(err_SCSI, err_COMPLETEDERR),         "ASPI - Command completed with errors."},
   {MakeEC(err_SCSI, err_InvalidSCSICmd),       "ASPI - Invalid SCSI command."},
   {MakeEC(err_SCSI, err_InvalidAdapter),       "ASPI - Invalid Host adapter number."},
   {MakeEC(err_SCSI, err_UNKNOWNERR),           "ASPI - Unkown error returned."}, 
   {MakeEC(err_SCSI, err_TimeOut),              "ASPI - Command timed out."},
   {MakeEC(err_SCSI, err_InvalidCMD),           "ASPI - Invalid parameter set in SRB."},
   {MakeEC(err_SCSI, err_FailedInit),           "ASPI - ASPI for Windows failed init."},
   {MakeEC(err_SCSI, err_ASPIIsBusy),           "ASPI - No resources available to executed command."},
   {MakeEC(err_SCSI, err_BufferToBig),          "ASPI - Buffer size is too big to handle!"}, 
   {MakeEC(err_HOST, err_NOADAPTER),            "Specified Host adapter not installed"},
   {MakeEC(err_HOST, err_FileNotFound),         "File could not be opened."},
   {MakeEC(err_HOST, err_ZeroLengthFile),       "File has a zero length."}, 
   {MakeEC(err_HOST, err_NoMemory),             "Could not allocate memory."}, 
   {MakeEC(err_CARTDEV, err_DIAGFAIL),          "Diagnostic failure."},
   {MakeEC(err_CARTDEV, err_CARTDEVERR),        "Unknown error with CARTDEV."},
   {MakeEC(err_CARTDEV, err_GameAddress),       "Out of bounds Address."},
   {MakeEC(err_CARTDEV, err_AddrTransferCount), "Invalid Address transfer length."},
   {MakeEC(err_CARTDEV, err_AddrDirection),     "Address direction invalid."},
   {MakeEC(err_CARTDEV, err_DPRTransferCount),  "Invalid DPR transfer count."},
   {MakeEC(err_CARTDEV, err_BufferNumber),      "Buffer number out of range."},
   {MakeEC(err_CARTDEV, err_BufferDirection),   "Buffer direction flag incorrect."},
   {MakeEC(err_CARTDEV, err_BufferAddress),     "Invalid buffer configuration."},
   {MakeEC(err_CARTDEV, err_BufferTransferCount),"Invalid buffer transfer count."},
   {MakeEC(err_CARTDEV, err_BufferReady),       "Buffer not ready."},
   {MakeEC(err_CARTDEV, err_INTDisabled),       "Selected Interrupt is not enabled."},
   {MakeEC(err_CARTDEV, err_SoundBoard),        "Sound Board - Digital Audio Clocking error."},
   {MakeEC(err_CARTDEV, err_CheckSumROM),       "Invalid ROM Checksum, firmware requires updating."},
   {MakeEC(err_CARTDEV, err_PageChecksum),      "Page Checksum failed."},
   {MakeEC(err_CARTDEV, err_Program),           "ROM -- Flash Programming Failure."},
   {MakeEC(err_GAME, err_ControlGame),          "Invalid parameter passed to HSI_ControlGame."},
   {MakeEC(err_MON,  err_XferLnMismatch),       "Transfer count is incorrect."},
   {MakeEC(err_MON,  err_BaduP),                "Invalid Processor parameter."},
   {MakeEC(err_MON,  err_InvalidCommand),       "Invalid Monitor command."},
   {MakeEC(err_MON,  err_CPUOffLine),           "CPU failed to respond to an NMI"},
   {MakeEC(err_MON,  err_BadMONError),          "Invalid Monitor error code returned."},

   {(EC)(0xffff), "***Invalid error code passed to HSI_GetErrorText()."}
};



EC
HSI_GetLastError(void)
{
   return(HSI_LastError);
}


char *
HSI_GetErrorText(EC locec)
{
   char *errP;
   int   i;

   i = 0;

   while((locec != ErrorMap[i].tag) && (ErrorMap[i].tag != (EC)0xffff))
      i++;

   errP = ErrorMap[i].text;

   return(errP);
}


void
HSI_SetTimeOutValue(DWORD  val) 
{
    HSI_TimeOut = val;    
}


DWORD
HSI_GetTimeOutValue(void)
{
    return(HSI_TimeOut);
}


static

char *VersionString = "Version - Windows 1.1 ""  "__DATE__" " __TIME__;

// The Major version changes manually, the minor version string changes
// every time the library is built.
char *
HSI_Version(void)
{
    return(VersionString);
}
