/*******************************************
 *
 *  SMPC SAMPLE PROGRAM Version 0.55
 *
 *   file : sspi.h
 *
 * author : s.uchida sega cs h/w r&d
 *
 *   date : 94/11/07
 *
 *******************************************/



#ifdef _GLOBAL_SUBSTANCE_
#define GLOBAL
#define VALUE(STR) = STR
#define _GSUB_
#else
#define GLOBAL extern
#define VALUE(STR)
#endif


GLOBAL float radian[12];
GLOBAL MENU_Body mm;
GLOBAL current_menu cur;
GLOBAL Uint8 MenuDev VALUE(0xff);

GLOBAL Uint8 csrmode VALUE(0);

GLOBAL Uint8 per_byte;

GLOBAL Uint8 contflag;
GLOBAL Sint16 spx[PERMAX],spy[PERMAX];
GLOBAL Uint8 spchg[PERMAX];
GLOBAL Uint16 spi VALUE(0);
GLOBAL Uint8 menudevchg VALUE(1);
GLOBAL void smpcdispsub(Uint8,Uint8);
GLOBAL void smpcdisporeg(Uint8,Uint8);

GLOBAL Uint16 linecolor[8][8];
GLOBAL Sint8 *itos(Uint32,Uint8,Uint8);
GLOBAL Sint8 *itosh2(Uint32);
GLOBAL void gcls();
GLOBAL void box(Uint8,Uint8,Uint8,Uint8);
GLOBAL void putstr(Uint8,Uint8,Sint8 *,Uint8);
GLOBAL void init_screen(void);
GLOBAL void screenout(void);
GLOBAL void getportstat(void);
GLOBAL Uint8 getperipheral(Uint8,Uint8);
GLOBAL Uint8 get1device(Uint8);
GLOBAL void PrintDeviceData(Uint8,Uint8);
GLOBAL void PrintOreg(void);
GLOBAL void intback(void);
GLOBAL void UserVblankStart(void);
GLOBAL void UserVblankEnd(void);
GLOBAL void SetVblank(void);
GLOBAL void UserSmpcInt(void);
GLOBAL void rbg_pad_action(Uint8 i);
GLOBAL void rtc(void);
GLOBAL void statusline(void);
GLOBAL void tomenuchk(Uint8);
GLOBAL void NotAvailable(void);
GLOBAL Uint8 waitsmpc(void);
GLOBAL Uint16 spcmd[PERMAX + 1][4][16];
GLOBAL Uint8 ireg[7],oreg[32*4];
GLOBAL Uint8 oregptr,devptr,sf;
GLOBAL perdata device[PERMAX + 1];
GLOBAL sprite spr[PERMAX];
GLOBAL portstat port[2];
GLOBAL MENU_Body mm;
GLOBAL Uint16 SpCmd[PERMAX+1][4][16];
GLOBAL Uint8 ProgramMode,MenuEnable;
GLOBAL Uint32 MainLoopCount VALUE(0);
GLOBAL Uint16 VBinCount VALUE(0);
GLOBAL Uint16 VBoutCount VALUE(0);
GLOBAL void putfdev(Uint8,Uint8,Uint8);
extern Uint8 Font8[];
extern Uint8 SpDat[16][16*16];
extern peripheral peri[];

