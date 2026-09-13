/******************************************
 *                                        *
 *   SMPC SAMPLE PROGRAM Version 0.56a    *
 *                                        *
 *    file : sspdef.h                     *
 *                                        *
 *  author : s.uchida sega cs h/w r&d     *
 *                                        *
 *    date : 94/11/09                     *
 *                                        *
 ******************************************/




/* ペリフェラルのボタンマスク */

#define TOPLINE 0
#define BORDERLINE 26
#define PORTSKIP 8
#define RGBMAX 31

#define UP 0x10
#define DOWN 0x20
#define LEFT 0x40
#define RIGHT 0x80
#define L_BTN 0x08
#define R_BTN 0x80
#define A_BTN 0x04
#define B_BTN 0x01
#define C_BTN 0x02
#define X_BTN 0x40
#define Y_BTN 0x20
#define Z_BTN 0x10
#define START 0x08
#define CLICKL 0x01
#define CLICKR 0x02
#define CLICKM 0x04
#define CLICKS 0x08

#define PDISPX 2
#define PDISPY 23


/* 色番号 */

#define BLACK   0
#define BLUE    1
#define RED     2
#define VIOLET  3
#define GREEN   4
#define SKYBLUE 5
#define YELLOW  6
#define WHITE   7


/* スプライト関連 */

#define SPRVRM 0x05c00000
#define CENTERX 160
#define CENTERY 112
#define SPNULL 0x2000
#define SPBASE 0x2020
#define SPSTEP 0x20
#define COLBASE 0x0000
#define COLSTEP 0x100

#define PERMAX 30
#define PORTMAX (PERMAX / 2)



/* ポートステータス */

#define NODEV  0xf0
#define DIRECT 0xf1
#define TAP6P  0x16
#define TAP4P  0x04

#define CLK1   0x21
#define CLK2   0x22
#define CLK3   0x23
#define CLK4   0x24
#define CLK5   0x25
#define CLK6   0x26
#define CLK7   0x27
#define CLK8   0x28
#define CLK9   0x29
#define CLKA   0x2a
#define CLKB   0x2b
#define CLKC   0x2c
#define CLKD   0x2d
#define CLKE   0x2e
#define CLKF   0x2f


/* ペリフェラルＩＤ */

#define STDPAD  0x02
#define MD3BPAD 0xe1
#define MD6BPAD 0xe2
#define MOUSE   0xe3
#define ALGSTK  0x15
#define KEYBRD  0x34
#define STAIR   0x13
#define UNKNOWN 0xff

/* プログラムのモード */

#define MENU 1
#define PPMSPR 2
#define PPMRBG 3
#define OREGSMP 4
#define PAINT 6
#define CMDTEST 7


/* メニュー定数 */

#define CANCEL 0x40
#define VALID  0x80

#define YESNO_YES 0
#define YESNO_NO 1



/* カラー合成マクロ */

#define RGB256(r,g,b) (0x0000 + (r&7)*4 + (g&7)*128 + (b&3)*8192)
#define RGB16(r,g,b) (r&7) + (g&7)*8 + (b&3) * 64
#define RGB555(r,g,b) ((r) + (g)*32 + (b)*1024)

/* ＳＭＰＣレジスタアドレス */

#define COMREG        0x2010001f
#define IREG          0x20100001
#define OREG          0x20100021
#define STATUSFLAG    0x20100061
#define STATUSREG     0x20100063
#define INTBACK       0x0010


/* アドレスデータ直接書き込み・読み込みマクロ */

#define pokeb(address,data) (*(Uint8 *)(address) = (Uint8)(data))
#define peekb(address)      (*(Uint8 *)(address))
#define pokew(address,data) (*(Uint16 *)(address) = (Uint16)(data))
#define peekw(address)      (*(Uint16 *)(address))
#define pokel(address,data) (*(Uint32 *)(address) = (Uint32)(data))
#define peekl(address)      (*(Uint32 *)(address))


/* 	ＳＭＰＣＢＵＳＹ判定マクロ */

#define SMPCBUSY (peekb(0x20100063) & 0x01)

/* スプライト関連 */

#define SPVRM 0x05c00000
#define CMD 0
#define LINK 1
#define MODE 2
#define COLBANK 3
#define PTNADRS 4
#define CHARSIZ 5
#define XA 6
#define YA 7
#define XB 8
#define YB 9
#define XC 10
#define YC 11
#define XD 12
#define YD 13
#define GTB 14
#define DUMMY 15

#define SYSCLIP 0
#define USRCLIP 1
#define LOCATE  2
#define PATTERN 3
#define ENDCMD  0

#define CMDSIZ sizeof(spcmd)

#define FADE_NON 0
#define FADE_IN 1
#define FADE_OUT 2



/* ペリフェラルのボタン押下情報構造体 */

typedef struct button {
	Uint8 A,B,C,X,Y,Z,S;
	Uint8 Up,Down,Left,Right,L,R;
	Uint8 ClickL,ClickR,ClickM;
} button;


/* ペリフェラルデータ構造体 */

typedef struct perdata {
    Sint8 name[40];				/* ペリフェラル名 */
    Sint8 shortname[10];		/*      〃        */
    Uint8 MDID,SaturnID;		/* ＩＤ           */
    Uint8 data[16];				/* データ         */
    Uint8 datamax;				/* データ数       */
    Uint8 connect;				/* 接続判定       */
    Uint8 port;					/* ポート番号     */
    Uint8 change;				/* 変更判定       */
    button Btn;					/* ボタン押下情報 */
    button lBtn;				/* 前回ボタン情報 */
} perdata;


typedef struct peripheral{
	Sint8 name[40];
	Sint8 shortname[10];
	Uint8 num;
	Uint8 MDID,SaturnID;
} peripheral;



/* ポートステータス構造体 */

typedef struct portstat {
	Uint8 id;					/* ポートステータス   */
	Sint8 name[40];				/* ポート状態         */
	Uint8 chg;					/* ステータス変更判定 */
} portstat;

typedef struct sprite{
	Sint16 x,y;
	Sint16 xa,ya;
	Sint16 xb,yb;
	Sint16 xc,yc;
	Sint16 xd,yd;
	Uint16 PtnAdrs;
	Uint16 ColBank;
	Sint16 zoom;
	Uint8 zoomenable;
	Uint8 speed;
	float radian;
} sprite;



/* メニュー構造体 */

typedef struct MENU_Body{
	Sint8 title[32];				/* メニュータイトル   */
	Sint8 item[48][32];				/* メニュー項目       */
	Uint8 xstep,ystep;				/* カーソルステップ値 */
	Uint8 column,line;				/* 縦・横項目数       */
	Uint8 lmenux,lmenuy;			/* 前回選択値         */
	Uint8 num;						/* 総項目数           */
	Uint8 menutype;					/* メニューのタイプ   */
	void (*menufunc)(Uint8,Uint8);	/* メニューから呼び出す関数 */
} MENU_Body;

typedef struct current_menu{
	Uint8 x,y;
	Uint8 cx,cy;
	struct MENU_Body menu;
} current_menu;

#define YN_WIN_V 0
#define YN_WIN_H 1
#define YN_YES 0
#define YN_NO 1
#define NVALID 0x80
#define CANCEL 0x40
#define MENU_CSRTYP_NORM 0x00
#define MENU_CSRTYP_REV  0x01
#define MENU_FUNC_DISABLE 0x00
#define MENU_FUNC_ENABLE 0x02

#define MENUITEM(mbody,no,str) strcpy(mbody.item[no],str);
#define MENUTITLE(mbody,str) strcpy(mbody.title,str);


/* 定数定義 */

#define ON 1
#define OFF 0
#define TRUE 1
#define FALSE 0
#define ENABLE 1
#define DISABLE 0

