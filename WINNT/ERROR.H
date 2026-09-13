/*
 //    error.h - 
 //
 //      error.h contains definitions for the ASPI manager error codes and
 //             the SCSI error codes. As well as errors that can occur in
 //             this library.
 //    
 //
 //    NOTES
 //        
 //    REFERENCES
 //        
 //    LANGUAGE
 //        ANSI C
 //    LIB
 //        
 //    SEE ALSO
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
 //        GBC   23 Jan 94   Initial Creation
 //
*/
#ifndef  _error_h
#define  _error_h

/* Error.h
 *
*/

/* EC the error code type is build from two pieces
 * the EC is a 16 bit value
 * the higher 8 bits is a group code indicating module or function grouping
 * of the error.
 * The lower 8 bits is the actual error code.
 * This provides for 255 modules with 256 errors each...
*/

/* Modules
*/
#define  err_LIB     1
#define  err_SCSI    2
#define  err_HOST    3
#define  err_CARTDEV 4
#define  err_GAME    5
#define  err_MON     6

#define  err_NOERROR ((EC)(0))


/* The LIB layer error codes
*/
#define  err_NOASPI           0     // No ASPI driver found
#define  err_ChannelNotAlloc  1     // logical channel not allocated.
#define  err_NoChannelsAvail  2     // no more channels available.
#define  err_NoCartdevFound   3     // didnt find a cartdev!
#define  err_LoopBackFailed   4
#define  err_BadPointer       5     // pointer > 1meg
#define  err_ProtMode         6     // error from protected mode stuff...
#define  err_GameNotReady     7     // game never became ready for the download...
#define  err_MemoryAllocFail  8     // Memory allocation failed...
#define  err_CreateEvent	  9		// Unable to create the ASPI wait event...
#define  err_ThreadTerminated 10    // Owning thread terminated


/* The SCSI layer error codes
*/
#define  err_ID_INVALID       0
#define  err_NOTARGET         1
#define  err_REQ_ABORTED      2
#define  err_COMPLETEDERR     3
#define  err_InvalidSCSICmd   4
#define  err_InvalidAdapter   5
#define  err_UNKNOWNERR       6
#define  err_TimeOut          7
#define  err_InvalidCMD       8
#define  err_FailedInit       9
#define  err_ASPIIsBusy      10
#define  err_BufferToBig     11


/* The HOST layer error codes
*/
#define  err_NOADAPTER        0     // Specified host adapter not installed
#define  err_FileNotFound     1     // file could not be opened.
#define  err_NoMemory         2     // could not allocate run-time memory
#define  err_ZeroLengthFile   3     // file empty

/* The CARTDEV layer error codes
*/

#define  err_DIAGFAIL               0     // Diagnostic failed
#define  err_GameAddress            1
#define  err_AddrTransferCount      2
#define  err_AddrDirection          3
#define  err_DPRTransferCount       4
#define  err_BufferNumber           5
#define  err_BufferDirection        6
#define  err_BufferAddress          7
#define  err_BufferTransferCount    8
#define  err_BufferReady            9
#define  err_INTDisabled            10
#define  err_CARTDEVERR             11
#define  err_SoundBoard             12
#define  err_CheckSumROM            13
#define  err_PageChecksum           14
#define  err_Program                15


/* The GAME layer error codes
*/

#define  err_ControlGame            0

/* The Monitor layer error codes
*/
#define err_XferLnMismatch          0
#define err_BaduP                   1
#define err_InvalidCommand          2
#define err_CPUOffLine              3
#define err_BadMONError             4
/*
*/


// This macro builds an EC  from the module and the error code
#define MakeEC(mod, err)   (EC)((mod << 8) | (err & 0xff))

extern   EC InterpretASPIStatus(unsigned char, ChannelID);
#endif
