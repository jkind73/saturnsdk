/*
 // HSI For Win '95 & NT
 // Uses Win32s 32 bit ASPI dll.
 //
 //    loopback.c -
 //
 //      Higher level loopback test code.
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
 //      EC    HSI_LoopBackTest(unsigned long int, int, int, unsigned char *, unsigned char *, int);
 //
 //     These globals are declared here:
 // 
 //        
 //     MODS
 //     GBC 27 Jan 94   Initial Creation
 //     GBC 03 May 94   Added the HSI_LoopBackTest function
 //     GBC 04 May 94   Added the HSI_DownloadMonitor function 
 //     GBC 12 May 94   Began the port to the watcom/flashtek environment
 //     GBC 20 May 94   Fixed problems with the LoopBackTest() function.
 //     GBC 17 Aug 95   Initial Win '95 Creation, from the original HSI32 DOS 
 //                     code. Modified heavily due to the new data structures 
 //                     as provided by Win32s ASPI implementation...
*/




#include    <windows.h>

#include    "scsidefs.h"
#include    "wnaspi32.h"

#include    "hsi32win.h"
#include    "error.h"
#include    "private.h"
#include    "scsi.h"
#include    "game.h"

extern  SRB_ExecSCSICmd     ExecSRB;

#define     BUF_SIZE (63L*1024L)

// this function appears here because the Watcom compiler did not have it...
WORD
random(WORD maxnum)
{
    return((WORD)(((DWORD)rand()*maxnum)/(RAND_MAX + 1)));
}


EC
HSI_LoopBackTest(CartDevBuffIdT dprout, CartDevBuffIdT dprin, 
                 unsigned long int count, short int buffsize, short int forcesize, 
                 BYTE * InP, BYTE * OutP, ChannelID CID, short int retrycnt)
{

    CmdHeaderT *cmdP;
    
    BYTE       *p,
               *pin,
               *pout;
    
    WORD        i,
                localbuffsize;
                
    EC          retcode;                
    
    while((int)count-- > 0)  {
    
        if(forcesize != 0)  {
            localbuffsize = forcesize;
        } else {
            localbuffsize = random(((WORD)(buffsize - sizeof(CmdHeaderT)))) + (WORD)sizeof(CmdHeaderT);
            
            if(localbuffsize <= sizeof(CmdHeaderT))
                localbuffsize = sizeof(CmdHeaderT) + 1;
        }
    
        // Fill the buffer with random data...
        p = (BYTE *)OutP;
        
        for(i = 0; i < localbuffsize; i++)  {
            *p++ = (BYTE)random(0xff);
        }

        cmdP = (CmdHeaderT  *)OutP;
        
        cmdP->ErrorCode     = 0;
        cmdP->Command       = Swap16(CMD_Loopback);
        cmdP->Sequence      = Swap16((WORD)count);
        cmdP->TargetCPU     = Swap16(uP_68000);
        cmdP->DataLength    = Swap32(localbuffsize);
        cmdP->Address       = Swap32(0x12345678L);
    
        // Now package is build, send it to the CARTDEV...
        // Read a buffer
        i = 0;
        
        do {
            // if the buffer is not ready retry up to retrycnt times...        
            retcode = HSI_WriteDPR(dprout, (CartDevBuffSizeT)localbuffsize, OutP, CID);
            
        } while((i++ < retrycnt) && (retcode == MakeEC(err_CARTDEV, err_BufferReady))); 
        
        if(retcode != err_NOERROR)
            return(retcode);
            
        i = 0;
        
        do {
        
            // if the buffer is not ready retry up to 10 times...        
            retcode = HSI_ReadDPR(dprin, (CartDevBuffSizeT)localbuffsize, InP, CID);
            
        } while((i++ < retrycnt) && (retcode == MakeEC(err_CARTDEV, err_BufferReady))); 
        

        if(retcode != err_NOERROR)
            return(retcode);
        
        // Now Compare the two buffers....
        pin     = (BYTE *) InP;
        pout    = (BYTE *) OutP;
         
        for(i = 0; (i < localbuffsize) && (*pin++ == *pout++); i++)
            ;
        
        if(i < localbuffsize)  {
            retcode = MakeEC(err_LIB, err_LoopBackFailed);
            return(retcode);
        }
    }
    return(err_NOERROR);
}                 
