/*
 //    hsi32win.h - 
 //
 //      hsi32win.h contains definitions for the Host SCSI Interface library. This
 //           file is to be included by clients of the HSI library code.
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
 //        GBC  21 Jan 94   Initial Creation
 //        GBC  02 Feb 94   Changed the names from Game to CartDev...
 //        GBC  04 May 94   Removed the HSI_QueryGame function...
 //        GBC  12 May 94   Ported to 32 bit watcom/flashtek environment
 //        GBC  15 Jun 94   Added ifdef C++ directives...
 //        GBC  11 Aug 95   Ported to the windows environment.
*/
#ifndef  _hsi32win_h
#define  _hsi32win_h


/* HSI32.h
 * 
*/

/* The Error Code type
*/
typedef unsigned int EC;

/* The following groups of defines is for the library function:
 *
 * HSI_ControlGame(GameCmdT          cmdcategory,
 *                 GameCmdSpecifierT cmdspec);
 *
 *
 *    The control Game command categories and command specifiers
 *    match the CARTDEV command definitions (and therefore should
 *    not be modified).
*/

/* Control Game command categories
*/

typedef enum {
   SCmdRESET      =  0x00,
   SCmdINTERRUPT  =  0x01,
   SCmdAddr       =  0x02,
   SCmdDPR        =  0x03,
   SCmdABUSMAP    =  0x04,
   SCmdMIDI       =  0x05,
   SCmdDIAGNOSTIC =  0x06,
   SCmdSCSI       =  0x07
} GameCmdT;

typedef  BYTE      GameCmdSpecifierT;

typedef  unsigned long int  CartDevAddrT;
typedef  unsigned long int  CartDevAddrSizeT;
typedef  BYTE      			CartDevBuffIdT;
typedef  unsigned short int CartDevBuffSizeT;

typedef  BYTE      			ChannelID;


/* Control Game command specifiers for the Reset command category
*/

#define  csSETSH2MAIN         0x00
#define  csCLEARSH2MAIN       0x01
#define  csPULSESH2MAIN       0x02
#define  csSETSH2SUB          0x03
#define  csCLEARSH2SUB        0x04
#define  csPULSESH2SUB        0x05
#define  csSETGAMESYSTEM      0x06
#define  csCLEARGAMESYSTEM    0x07
#define  csPULSEGAMESYSTEM    0x08
#define  csSETSOUND           0x09
#define  csCLEARSOUND         0x0a
#define  csPULSESOUND         0x0b

/* Control Game command specifiers for the Interrupt command category
*/

#define  csNMISH2MAIN         0x00
#define  csNMISH2SUB          0x01
#define  csINTSOUND           0x02
#define  csAIRQBASE           0x20    /* AIRQs are 0x20 to 0x2F */


/* Control Game command specifiers for the Addr command category
*/

#define  csACCESSCARTDEV      0x00
#define  csACCESSGame         0x01
#define  csSETWAIT            0x04    /* wait if access invalid */
#define  csCLEARWAIT          0x05    /* garbage if access invalid */
#define  csSETPROTECTBASE     0x10    /* 0x10 to 0x17, write protects for 2Mb areas */
#define  csCLEARPROTECTBASE   0x20    /* 0x20 to 0x27 */
#define  csSETAUTOACCESS      0x30    /* access switched to CartDev for SCSI */
#define  csCLEARAUTOACCESS    0x31    /* access not switched automatically */


/* Control Game command specifiers for the ABusMap command category
*/

/* selects address of Addr on the ABus
 *    0x00 to 0x03
 *    MAP_Addr0 is in bit0
 *    MAP_Addr1 is in bit1
*/
#define csABUSMAPAddrBASE    0X00    

/* selects address of everthing else on the ABus
 *    0x10 to 0x13
 *    MAP_PER0 is in bit0
 *    MAP_PER1 is in bit1
*/
#define csABUSMAPPERBASE    0X10    

/* Control Game command specifiers for the MIDI command category
*/

#define  csENABLEMIDI1  0x00
#define  csDISABLEMIDI1 0x01
#define  csENABLEMIDI2  0x02
#define  csDISABLEMIDI2 0x03



/* Control Game command specifiers for the CartDev command category
*/

#define  csTESTCARTDEV  0x00

/* Special buffer numbers for reading CARTDEV status
*/
#define  STATUS_BUF_ID  ((CartDevBuffIdT)(16))

/* This is the default timeout value used on SCSI commands...
*/
#define HSI_DEFAULT_TIMEOUT     (5*1000)     // 5 seconds as milliseconds....



#define ESCAPE      0x1b
#define BufferBusy  MakeEC(err_CARTDEV, err_BufferReady)


/* The different types of CARTDEV devices available
*/
typedef enum {
    CD_UNKNOWN,
    CD_MARS,
    CD_SATURN
} CartdevT;


#ifdef __cplusplus
extern "C" {
#endif

/* PROTOTYPES for the HSI function library.
*/
// From the file SCSI.C
EC          HSI_AllocateChannel(ChannelID *);
EC          HSI_ReleaseChannel(ChannelID);
EC          HSI_SetSCSI_ID(BYTE);
BYTE        HSI_GetSCSI_ID(void);
CartdevT    HSI_GetCartdevType(void);
EC          HSI_SCSIInquiryText(char *);
void        HSI_SCSIHostText(char *, BYTE *);
EC          HSI_ResetSCSI(void);
EC          HSI_ScanSCSIBus(void);
EC          InterpretASPIStatus(BYTE, ChannelID);
EC          HSI_TestUnitReady(BYTE);
EC          HSI_RequestSense(BYTE, BYTE *);
EC          HSI_ProcessCheckCondition(ChannelID);


extern   EC    HSI_Initialize(BYTE, BYTE);
extern   EC    HSI_GetLastError(void);
extern   char *HSI_GetErrorText(EC);
extern   char *HSI_Version(void);

extern  void    HSI_SetTimeOutValue(DWORD  val);
extern  DWORD   HSI_GetTimeOutValue(void);

extern   EC    HSI_WriteDPR(CartDevBuffIdT, CartDevBuffSizeT, BYTE *, ChannelID);
extern   EC    HSI_ReadDPR(CartDevBuffIdT, CartDevBuffSizeT, BYTE *, ChannelID);
extern   EC    HSI_ReadAddr(CartDevAddrT, CartDevAddrSizeT, BYTE *, ChannelID);
extern   EC    HSI_WriteAddr(CartDevAddrT, CartDevAddrSizeT, BYTE *, ChannelID);
extern   EC    HSI_ControlGame(GameCmdT, GameCmdSpecifierT, ChannelID);
extern   EC    HSI_LoopBackTest(CartDevBuffIdT, CartDevBuffIdT, unsigned long int, 
                                short int, short int, BYTE *, BYTE *, ChannelID, short int);

// Debugging functions...
//extern   void  HSI_SCSIHostText(char *p, BYTE *id);


// Windows specific...
extern   int        MEditPrintF(HWND, PTSTR , ...);
extern   BOOLEAN    DownloadCOFF(HWND, char *, BOOLEAN, BOOLEAN, BOOLEAN);


#ifdef __cplusplus
}
#endif

extern   BYTE 		HSI_QID;
extern   BYTE 		HSI_QLUN;
extern   BYTE 		HSI_QHost;               // The INDEX of the ID of the host adapter to use
extern   BYTE 		HSI_NumAdapters;         // The number of host adapters present.
extern   EC       	HSI_LastError;
extern   CartdevT 	HSI_CartdevType;         // The type of cartdev found.
extern   BYTE 		ASPI_Inited;             // Non zero if ASPI is alive

extern   void      *LastSenseP;              // used by debugging code only!
extern   BOOLEAN    CartdevFound;            // if true there is a Cartdev connected.

extern   BYTE     	HSIDebug;
extern   HWND       HSI_hwnd;
extern   DWORD      ASPIStatus;


#endif  // _hsi32_h defined
