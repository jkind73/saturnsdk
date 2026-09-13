// This is the private header file for the HSI Windows '95 Port



#define MAX_HOST_ADAPTERS   4

// This is the array of inquiry text strings, and host data

typedef struct {
   BYTE     HostID;
   char     HostText[50];                 // SCSI Mgr ID, Host Adapter ID, Host Unique

   struct {
      BYTE      DeviceType;
      BYTE      Lun[8];                 // Lun allocated ?...
      char      InquiryText[32];
   } Targets[8];

} HostT;

extern   HostT Hosts[MAX_HOST_ADAPTERS];
extern   EC HSI_ProcessCheckCondition(ChannelID);
extern   void  *LastSRB;


// Timer.c externs...
extern  void   InitTimer(void);
extern  DWORD  DeltaTime(void);
extern  DWORD  HSI_TimeOut;

// aspi.c externs...
extern	DWORD  _fastcall Swap32(DWORD);
extern	WORD   _fastcall Swap16(WORD);


#define  GetTime                0x2c  // DOS get time int 0x21 function....

// These are just the selected values for the control game command,
// these defines are needed for the HSI_DownloadMonitor function...
// The reset of these defines are found in control.h in the CARTDEV code.

#define ccReset                 0x00
#define ccMonRAM                0x03
#define ccDiagnostic            0x06
#define ccCartDev               0x07

#define csSetAll                0x0c
#define csinitBufferConfig0     0x30    /* 0x30 loads buffer config 0, 1 14K in */
#define csClearAll              0x0d

// And for MARS Cartdev:
#define csSetGameSystem         0x06
#define csClearGameSystem       0x07
#define csAccessCartDev         0x10
#define csAccessGame            0x20
#define csSetSplit              0x50
#define csClearSplit            0x60

#define csSetVisible            0x00
#define csClearVisible          0x01
					    

 
#define	BUFFER_MODE 	0x1

