/*
ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออัอออออออธ
ณ File name  ฏ game.h                                                ณ Headerณ
ณ Author     ฏ Geoff Caras                                           ิอออออออฐ
ณ                                                                            ณ
ณ              The Igneous Group                                             ณ
ณ              1836 17th Avenue, Suite D                                     ณ
ณ              Santa Cruz CA 95062                                           ณ
ณ              (408) 475-8194     FAX: (408) 475-8193                        ณ
ณ              GeoffC@igneous.com                                            ณ
ณ                                                                            ณ
ณ Date       ฏ 18 Jul 95                                                     ณ
ณ Version    ฏ 1.00                                                          ณ
ณ                                                                            ณ
รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Description:                                                               ณ
ณ This file contains the minimum to define the mechanism to send commands    ณ
ณ to the game...                                                             ณ
ณ                                                                            ณ
ณ Revision History:                                                          ณ
ณ                                                                            ณ
ณ 18 Jul 95 gbc Created                                                      ณ
ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
*/
#ifndef _game_h
#define _game_h
typedef enum RegisterEnum {
    // SH2 registers...
    reg_R0,           reg_R1,           reg_R2,         reg_R3,     
    reg_R4,           reg_R5,           reg_R6,         reg_R7,     
    reg_SH2_R8,       reg_SH2_R9,       reg_SH2_R10,    reg_SH2_R11,
    reg_SH2_R12,      reg_SH2_R13,      reg_SH2_R14,    reg_SH2_R15,
    reg_SH2_PC,       reg_SH2_PR,       reg_SH2_GBR,    reg_SH2_VBR,
    reg_SH2_MACL,     reg_SH2_MACH,     reg_SH2_SR,     reg_SH2_EX, 
  
    // 68K registers
    reg_68K_D0,       reg_68K_D1,        reg_68K_D2,    reg_68K_D3,    
    reg_68K_D4,       reg_68K_D5,        reg_68K_D6,    reg_68K_D7,    
    reg_68K_A0,       reg_68K_A1,        reg_68K_A2,    reg_68K_A3,    
    reg_68K_A4,       reg_68K_A5,        reg_68K_A6,    reg_68K_A7,
    reg_68K_SSP,      reg_68K_USP,       reg_68K_SR,    reg_68K_EXFLAG,
    reg_68K_FUNCCODE, reg_68K_ERRORADDR, reg_68K_INST,

    reg_INVALID
    
} RegisterEnumT;

typedef struct SH2_RegisterSetStruct {
    DWORD  R0;    
    DWORD  R1;    
    DWORD  R2;    
    DWORD  R3;    
    DWORD  R4;    
    DWORD  R5;    
    DWORD  R6;    
    DWORD  R7;    
    DWORD  R8;    
    DWORD  R9;    
    DWORD  R10;    
    DWORD  R11;    
    DWORD  R12;    
    DWORD  R13;    
    DWORD  R14;    
    DWORD  R15;    
    DWORD  PC;
    DWORD  PR;
    DWORD  GBR;
    DWORD  VBR;
    DWORD  MACL;
    DWORD  MACH;
    DWORD  SR;
    WORD  EXFLAG;
} SH2_RegisterSetT;


typedef enum SH2EXFLAGEnum {
    EXFLAG_Startup      = 0xff,
    EXFLAG_CPUHalted    = 0x0,
    EXFLAG_CPURinning   = 0x1,
    EXFLAG_EXEPTION4    = 0x4,
    EXFLAG_EXEPTION6    = 0x6,
    EXFLAG_EXEPTION9    = 0x9,
    EXFLAG_EXEPTION10   = 0xa,
    EXFLAG_EXEPTION12   = 0xc,
    EXFLAG_EXEPTION32   = 0x20
} SH2EXFLAGT;


typedef struct M68K_RegisterSetStruct {
    DWORD  D0;    
    DWORD  D1;    
    DWORD  D2;    
    DWORD  D3;    
    DWORD  D4;    
    DWORD  D5;    
    DWORD  D6;    
    DWORD  D7;    
    DWORD  A0;    
    DWORD  A1;    
    DWORD  A2;    
    DWORD  A3;    
    DWORD  A4;    
    DWORD  A5;    
    DWORD  A6;    
    DWORD  A7;    
    DWORD  SSP;
    DWORD  USP;
    WORD  SR;
    WORD  EXFLAG;
    WORD  FUNCCODE;
    DWORD  ERRORADDR;
    WORD  INST;
} M68K_RegisterSetT;


typedef struct UBCStruct {
    WORD  BARAH;
    WORD  BARAL;
    WORD  BAMRAH;
    WORD  BAMRAL;
    WORD  BBRA;
    WORD  BARBH;
    WORD  BARBL;
    WORD  BAMRBH;
    WORD  BAMRBL;
    WORD  BBRB;
    WORD  BDRBH;
    WORD  BDRBL;
    WORD  BDMRBH;
    WORD  BDMRBL;
    WORD  BRCR;
} UBCT;

typedef struct CmdHeaderStruct {
    WORD       ErrorCode;
    WORD      Command;
    WORD      Sequence;
    WORD      TargetCPU;
    
    DWORD      DataLength;
    DWORD      Address;
} CmdHeaderT;


typedef enum MonitorCmdEnum {
    CMD_Stop            = 0,
    CMD_ReadRegisters   = 1,
    CMD_WriteRegisters  = 2,
    CMD_ByteRead        = 3,
    CMD_WordRead        = 4,
    CMD_LongRead        = 5,
    CMD_ByteWrite       = 6,
    CMD_WordWrite       = 7,
    CMD_LongWrite       = 8,
    CMD_Go              = 9,
    CMD_Step            = 10,
    CMD_Loopback        = 11,
#ifdef  _pmars
    CMD_GetBankNum      = 12, 
#endif
    CMD_Version         = 13,
    CMD_ReadUBC         = 14, 
    CMD_WriteUBC        = 15,
#ifdef  _pmars
    CMD_MakeSafe        = 16,
    CMD_SimulateBoot    = 17

#else
    CMD_MakeSafe        = 16
#endif
} MonitorCmdT;

typedef struct {
   CmdHeaderT  SH2Main;
   CmdHeaderT  SH2Sub;
   CmdHeaderT  M68K;
   /*DWORD      NMICPUs;*/
   char        RevString[8];
   DWORD      TargetReady;
   DWORD      CartDevReady;

   DWORD      NMICPUs;
   WORD      HostRequest;
   WORD      MakeSafe;
} StatusBuffT;


typedef enum MonitorErrorsEnum { 
    merr_NoError            = 0,
    merr_BuffIntegrity,
    merr_XferLnMismatch,
    merr_InvalidProcessor,
    merr_InvalidCommand,
    merr_UalignAccAtmpt,
    merr_UalignPc,
    merr_InvalidAddress,
    merr_StepConflict,
    merr_IllegalStackPtr,
    merr_SH2MainDead,
    merr_SH2SubDead,

#ifdef  _pmars
    merr_NoGenHeader,
    merr_UnalSH2Block,
    merr_UnalSDRamDest,
    merr_BadLoadAddr,
    merr_BadSH2Length,
    merr_UnalMasterPC,
    merr_BadMasterPC,
    merr_UnalSlavePC,
    merr_BadSlavePC,
    merr_UnalMasterVBR,
    merr_BadMasterVBR,
    merr_UnalSlaveVBR,
    merr_BadSlaveVBR,
#endif    

    merr_CPUOffLine         = 127

} MonitorErrorsEnumT;

typedef enum GameuPEnum {
    uP_SH2_Main = 1,
    uP_SH2_Sub  = 2,
    uP_68000    = 4
} GameuPT;

#endif
