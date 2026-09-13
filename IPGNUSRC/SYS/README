
      GNU C用SEGASATURN IP(イニシャルプログラム)作成ドキュメント


０．はじめに
~~~~~~~~~~~~
  GNU C環境でIP(イニシャルプログラム)を作成するプログラムを提供致します。
IP作成は、弊社から提供の
    SEGASATURN Developer's Information STN-11
      「ブートシステム情報提供」
を参照して、プログラムを変更し makeすればIPを作成することができますが、
作成にあたりいくつか注意点と入手する必要なツールがありますので以下に記し
ます。

１．イニシャルプログラムの構成
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SYS_ID.SRC    SYSTEM IDデータファイル
                  (ユーザ記述ファイルになります。)
　　SYS_SEC.O     セキュリティコードファイル
    SYS_ARE?.O    エリアコードファイル(対応しないエリアコードはリンクしない)
        SYS_AREJ.O -- エリアコード(対応エリア:日本)
        SYS_ARET.O -- エリアコード(対応エリア:アジアNTSC地域)
        SYS_AREU.O -- エリアコード(対応エリア:北米など)
        SYS_AREE.O -- エリアコード(対応エリア:ヨーロッパなど)
    SYS_INIT.O    
    SMPSYS.C      アプリケーションイニシャルプログラムのサンプル
    　　　　　　　(そのままでも使用できるプログラムとして提供。)
    MAKEFILE      IP作成メイクファイル(PC版)
    MK.BAT        IP作成バッチファイル(PC版)

２．IP作成手順
~~~~~~~~~~~~~~
　提供のメイクファイル、バッチファイルを起動することでIPを作成することができ
ますが、環境変数およびツールが必要です。
　(1) 環境変数 SEGALIBAWKの設定
　　「４．アセンブラについての注意」を参照してください。
　(2) awkツール(gawk、gawk-emxなど)
　　「５．gawk.exe(gawk-emx.exe)の取得方法」を参照してください。
　(3) Sフォーマットからバイナリへの変換ツール(PC版)
　　セガサターン技術情報フォーラムにアップされているs28tobin.exeの使用
　(4) COFFフォーマットからバイナリへの変換ツール(Indy版)
    coff2binの使用

３．SYSTEM IDデータファイル変更時の注意点
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
　SYSTEM IDデータファイルは、SEGASATURNで起動できるCDとして正確に記述する必要
があります。この記述についての間違いがかなり多く、その中でも特に間違いが多い個
所を記します。
　(1) メーカーID
     間違っているとSEGAのロゴが表示されません。
  (2) 対応エリアシンボル
  　・対応エリアシンボルをすべてのエリア対応と記述するミスが多い。
  　・このシンボルとエリアコードファイルのリンクが間違っている。
  (3) 1stREAD開始アドレス(F0番地)
  　・このアドレスとプログラムの開始アドレスが違うため、プログラムが起動しない
  　　場合がある。
  　・SMPSYS.C をそのまま使用する場合は、APP_ENTRYで宣言しているアドレスを1st
      READ開始アドレスと同じにしなければならない。
<SYS_ID.SRC　日本だけの場合>
    ;=======================================================================
    ;    sys_id.src -- System ID for 3rd Party        (Ver.1994-11-11)
    ;    gasp のバグ対応（９行目）for SBL5.0        (Ver.1995-07-27)
    ;=======================================================================
        .SECTION SYSID,CODE,ALIGN=4
    ;
        .SDATA    "SEGA SEGASATURN "    ;00:ハードウェア識別子(変更不可)
        .SDATA    "SEGA TP KAISHA-A"    ;10:メーカーＩＤ
        .SDATA    "999999999 V1.","0","0","0"    ;20:商品番号、バージョン
        .SDATA    "19941122CD-1/1  "    ;30:リリース年月日、デバイス情報 
        .SDATA    "J               "    ;40:対応エリアシンボル
        .SDATA    "J               "    ;50:対応ペリフェラル
        .SDATA    "GAME TITLE      "    ;60:ゲーム名
        .SDATA    "                "    ;70:
        .SDATA    "                "    ;80:
        .SDATA    "                "    ;90:
        .SDATA    "                "    ;A0:
        .SDATA    "                "    ;B0:
        .SDATA    "                "    ;C0:
        .DATA.L    H'00000000,H'00000000,H'00000000,H'00000000    ;D0:
        .DATA.L    H'00001800,H'00000000,H'00000000,H'00000000    ;E0:
        .DATA.L    H'06010000,H'00000000,H'00000000,H'00000000    ;F0:
    ;
        .END
    ;====== End of file ====================================================

４．アセンブラについての注意
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  gasm.bat は、SHアセンブラ用のソースファイルを GNUアセンブラ用のソースファイル
に変換してアセンブルするユーティリティです。
　使用しているアセンブラソースファイルをSH用と共通にするため、このバッチファイ
ルを使用しています。
　gasm.bat を使うためには以下のような準備が必要です。
(1) gasm.bat, gawk.exe(またはgawk-emx.exe), as.exe, gasp.exe をパスの通ったディ
  レクトリに置きます。
(2) 環境変数 SEGALIBAWK に awk のスクリプトファイルのあるディレクトリを指定し
　ます。autoexec.batなどに登録してください。
  ＜例＞
　　set SEGALIBAWK=C:\SGL\SYS
(3) awk のスクリプトファイル（comment.awk, equate.awk, gasp.awk, keyword.awk,
  pool.awk, section.awk）を SEGALIBAWK に指定したディレクトリに置きます。

５．gawk.exe(gawk-emx.exe)の取得方法
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  GNUへの移植にあたり、アセンブラソースファイルを日立アセンブラと共通にするた
め、awk(パターン処理言語)を利用しています。awkはUNIX上では標準添付されるもので
すが、DOSでは提供されていません。
  以下にDOS版のawk(gawk)を入手する一例を記します。

＜例＞NIFTY-Serveからftpを利用してgwakを取得する方法
　NIFTY-Serveで'＞'のプロンプトが出ている所から「go ftp」とするとftpが利用でき
ます。ftpとはfile transfer protocolの略で専らインターネット上でファイルを転送す
る手順です。「ftp://ftp.iij.ad.jp/pub/dos/awk/gawk320a.zip」を取得しています。
（以下の手順でgawkを入手できます。)

|＞go ftp
|
|ftp     FTP
| 1. ご案内／利用方法     2. anonymous ftp
| 3. archie検索
|＞2
|
|anonymous ftp
| 1. 任意のサイトに入る       2. ftp.web.ad.jp に入る
| 3. ftp.iij.ad.jp に入る
|＞3
|パス名 (改行のみルートディレクトリ  例: pub ) 
|：pub
|ホスト名: ftp.iij.ad.jp
|パス名  : /pub/dos/awk
|確認 (1:OK  2:NG)
|：1
| ftp.iij.ad.jpに接続しています. *
|ftp.iij.ad.jp FTP server (Version wu-2.4(5) Thu Jun 1 11:55:10 JST 1995) ready.
|Guest login ok, send your complete e-mail address as password.
|
|* Welcome, IIJ archive user!  This is an FTP server of IIJ.  If have any
|unusual problems, please report them via e-mail to ftp@ftp.iij.ad.jp
|If you do have problems, please try using a dash (-) as the first character
|of your password -- this will turn off the continuation messages that may
|be confusing your ftp client.
|
|* Information of the Internet service of IIJ is in pub/info.
|
|* If you are using newer ftp client, you can find archive file by the 
|command ``site index filename''.
|
|* There are some extensions to the FTP server such that if you
|specify a filename (when using a RETRIEVE command) such that:
|
|True Filename Specified Filename  Action
|------------- ------------------- ---------------------------------------
|<filename>.Z  <filename>          Uncompress file before transmitting
|<filename>.gz <filename>          Gunzip file before transmitting
|<filename>    <filename>.Z        Compress <filename> before transmitting
|<filename>    <filename>.gz       Gzip <filename> before transmitting
|<filename>    <filename>.tar      Tar <filename> before transmitting
|<filename>    <filename>.tar.Z    Tar and compress <filename> before
|                                  transmitting
|<filename>    <filename>.tar.gz   Tar and gzip <filename> before
|                                  transmitting
|<directory>   <directory>.tar.Z   Tar and compress <directory> before
|                                  transmitting
|<directory>   <directory>.tar.gz  Tar and gzip <directory> before 
|                                  transmitting
|==========================================================================
|
|
|Guest login ok, access restrictions apply.
|Type set to I.
|
|接続完了
|Please read the file README
|  it was last modified on Wed May 31 16:28:19 1995 - 105 days ago
|Please read the file README.dos
|  it was last modified on Wed Sep 13 10:12:49 1995 - 0 days ago
|CWD command successful.
|ディレクトリ情報取得中です. ***
|ホスト名: ftp.iij.ad.jp
|パス名  : /pub/msdos/awk/
|番号  登録日時            バイト    データ名
|   9  --/--/-- --:--           0 D  .
|   8  --/--/-- --:--           0 D  ..
|   7  95/02/24 --:--         785 F  00_index.txt
|   6  91/06/12 --:--       98194 F  awk320.zip
|   5  91/06/12 --:--       71366 F  awk320sr.zip
|   4  90/05/21 --:--       14085 F  awk_rev3.zip
|   3  94/06/14 --:--      229739 F  gawk215a.zip
|   2  94/06/14 --:--      556909 F  gawk215s.zip
|   1  89/12/07 --:--        1513 F  phf.zip
|番号 (F:フィルタ) 
|＞6
|ホスト名: ftp.iij.ad.jp
|データ名: awk320.zip
|確認 (1:OK  2:NG)
|：1
|転送中です. **
| 98194バイト転送しました. 
|処理 (1:ダウンロード  E:終了)
|＞1
|プロトコル (1:XMODEM  2:BPLUS  E:終了)
|：2
|ダウンロードファイルを格納する準備をしてください(BPLUS)
| 98194バイトあります
|ファイル名 (改行のみで終了)
|：gawk320a.zip
|－ダウンロード開始－
|－ダウンロード終了－

６．zip圧縮の伸張ツールの取得方法
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
　拡張子.zipは海外ではメジャーな圧縮データフォーマットです。５．にてダウ
ンロードしたファイルはzip形式で圧縮されています。日本ではまだこの.zipの
圧縮/伸張ツールの保有者は少ないようで、テクニカルサポートのアンケートの
回答からも入手方法がわからないという声もあります。
　zipを伸張するツールは、シェアウェアとして提供されており、以下に例を記
します。
  ・シェアウェア
　　　Windows版 WinZip (NIFTY-Serve FGUI)
  　　DOS版  pkunzip (ftp://ftp.iij.ad.jp./pub/modos-j/TeX/emtex/disk1/)
　・フリーウェア
　　　DOS版　unzip (NIFTY-Serve FPCUPRO)
　zipの伸張ツールをもっていない方は、上記のツールを入手するようにお願い
します。
　　　　　　　　　　　　　　　　　　　　　　　　　　　　以　上
