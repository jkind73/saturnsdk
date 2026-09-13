/*
 // HSI For Win '95 & NT
 // Uses Win32s 32 bit ASPI dll.
 //
 //     control.c -
 //
 //        contains code to control features of the SEGA Game CARTDEV
 //        development environment.
 //     
 //     
 //        Written by the Igneous Group under agreement with Sega Of America.
 //          The Igneous Group
 //          1836 17th Ave, Suite D
 //          Santa Cruz, CA 95062
 //          408 475 8194 voice
 //          408 475 8193 fax
 //         
 //          Geoff Caras   GeoffC@igneous.com
 //
 //          Copyright (C) 1995, Sega Of America, Inc.
 //          All Rights Reserved
 //
 //
 //     NOTES
 //            
 //     REFERENCES
 //            
 //     LANGUAGE
 //            ANSI C
 //
 //     LIB          This code comprises the HSI library.
 //            
 //     SEE ALSO The include files (hsi.h) for application info.
 //
 //     These functions are defined here:
 //
 //        EC     HSI_ControlGame(CartDevCmdT, CartDevCmdSpecifierT, ChannelID);
 //
 //     These globals are declared here:
 // 
 //        BYTE HSI_QID;
 //        
 //     MODS
 //     GBC 27 Jan 94   Initial Creation
 //     GBC 04 May 94   Removed the HSI_QueryGame function...
 //     GBC 12 May 94   Ported to the Watcom/flashtek 32 bit environment
 //     GBC 17 Aug 95   Initial Creation, from the original HSI32 DOS code. Modified heavily due
 //                     to the new data structures as provided by Win32s ASPI implementation...
*/




#include    <windows.h>

#include    "scsidefs.h"
#include    "wnaspi32.h"

#include    "hsi32win.h"
#include    "error.h"
#include    "private.h"

#include    "scsi.h"

extern  SRB_ExecSCSICmd     ExecSRB;

EC
HSI_ControlGame(GameCmdT cmd, GameCmdSpecifierT cmdspec, ChannelID cid)
{
    EC      retcode;
    BYTE    lun;


    HANDLE  ASPICompletionEvent;
    DWORD   ASPIEventStatus;

    if(CartdevFound == FALSE)
        return(MakeEC(err_LIB, err_NoCartdevFound));


    if(Hosts[HSI_QHost].Targets[HSI_QID].Lun[cid] != TRUE) {

        retcode = MakeEC(err_LIB, err_ChannelNotAlloc);
        return(retcode);

    } else {

        lun = cid;

    }

    retcode = err_NOERROR;


    // Creat an event, no security attributes, manual reset, unsignaled, unnamed

    if((ASPICompletionEvent = CreateEvent(NULL, FALSE, FALSE, NULL)) == NULL) {
        // Unable to create the completion event.
        if(HSIDebug != 0) {
            MessageBox( HSI_hwnd,
                        "HSI Library -- HSI_ControlGame()",
                        "Unable to create completion event.",
                        MB_ICONSTOP
                       );

        }

        return(MakeEC(err_LIB, err_CreateEvent));
    }



    // Set one of the bits in the Game CARTDEV hardware using the
    // Vendor Specific command -- Control Game.

    memset(&ExecSRB, 0, sizeof(ExecSRB));

    ExecSRB.SRB_Cmd             = SC_EXEC_SCSI_CMD;
    ExecSRB.SRB_HaId            = HSI_QHost;
    ExecSRB.SRB_Flags           = SRB_EVENT_NOTIFY;
    ExecSRB.SRB_Target          = HSI_QID;
    ExecSRB.SRB_Lun             = lun;
    ExecSRB.SRB_SenseLen        = SENSE_LEN;
    ExecSRB.SRB_PostProc        = ASPICompletionEvent;

    ExecSRB.SRB_CDBLen          = 6;

    ExecSRB.CDBByte[0]          = CartDev_CONTROL;
    ExecSRB.CDBByte[1]          = lun << 5;
    ExecSRB.CDBByte[2]          = cmd;
    ExecSRB.CDBByte[3]          = cmdspec;
    ExecSRB.CDBByte[4]          = 0;
    ExecSRB.CDBByte[5]          = 0;

    LastSRB        = (void *)&ExecSRB;
    LastSenseP     = &ExecSRB.SenseArea[0];
                                             
    ASPIStatus = SendASPI32Command((LPSRB) &ExecSRB);


    if(ExecSRB.SRB_Status == SS_PENDING)
        ASPIEventStatus = WaitForSingleObject(ASPICompletionEvent, HSI_TimeOut);


    switch(ASPIEventStatus) {
        case    WAIT_OBJECT_0:
            ResetEvent(ASPICompletionEvent);
            break;

        case    WAIT_ABANDONED:
            ResetEvent(ASPICompletionEvent);
            CloseHandle(ASPICompletionEvent);
            return(MakeEC(err_LIB, err_ThreadTerminated));
            break;

        case    WAIT_TIMEOUT:
            ResetEvent(ASPICompletionEvent);
            CloseHandle(ASPICompletionEvent);
            return(MakeEC(err_SCSI, err_TimeOut));
            break;

        default:
            return(MakeEC(err_SCSI, err_UNKNOWNERR));
    }

    retcode = InterpretASPIStatus(ExecSRB.SRB_Status, lun);

    HSI_LastError = retcode;

    CloseHandle(ASPICompletionEvent);

    return(retcode);
}

                                                     
