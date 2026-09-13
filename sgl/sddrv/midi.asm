; 93'10～	(C)SEGA sound Room   AM2 Yamamoto
;
;	SCSP Contol Program      
;

	include	SCSP.LIB

	external	PEG_key_off			; [  TRGT.ASM]
	external	Note_on
	external	Note_off
	external	MIXER_wr,PRG_chg
	external	CTRL_10,CTRL_12,CTRL_13

	global		MIDI_ctrl

;  <<<< 検索文字列 >>>>
;
;	  CTRL_01	モジュレーション  ホィール			
;	  MIDI_En	ピッチ  ベンド					
;	  PRG_chg	プログラム （音色）チェンジ			
;	  CTRL_5B	Ｅffect チェンジ（ＤＳＰ Ｍicro Ｐrogram 更新）	
;	  CTRL_40	ダンパー					
;	  CTRL_20	ＢＡＮＫチェンジ	----> CHG.ASM		
;	  CTRL_10	ＭＩＸＥＲチェンジ				
;	  CTRL_07	音量コントロール				
;	  CTRL_0A	ＰＡＮコントロール				
;	  CTRL_11	Ｅffect パン チェンジ				
;	  CTRL_47	Ｅffect Ｖol チェンジ				
;	  CTRL_50	3D

	external	CTRL_20

;************************************************************************
;【 機 能 】 割込みにてバッファリングされたＭＩＤＩデータを取り出して	*
;	     ノートオン/オフ、プログラムチェンジ、コントロールチェンジ	*
;            等を制御する。						*
;【 入 力 】a5/a6: FH1005 top / work RAM top				*
;	    d0.w : MIDI buffer read offset point			*
;【 出 力 】nothing							*
;【destroy】d0.w/d1.w/d2.b/d3.b/d4.w					*
;【 hold  】a5/a6							*
;************************************************************************

; A.Miyazawa	{

;		global	MIDI_ctrl
;MIDI_ctrl:	addq.b	#1,_MIDI_RCV_RDPT(a6)	; 更新 11/16
;		add.w	d0,d0			;
;		add.w	d0,d0			;
;		lea	_MIDI_RCV_BF(a6),a1	;
;		adda.w	d0,a1			;
;		;-------------------------------;
;		global	MIDI_ctrl_pt
;MIDI_ctrl_pt:	bsr.w	set_MIDI_OUT_BF		; SCSP-MIDI OUT
;		;-------------------------------;
;		move.b	(a1)+,d0		; Priority(7-3) & コマンド(2-0)
;		move.b	(a1)+,d1		; 発音管理番号 ＆ MIDI ch#
;		move.b	d1,d2			;
;		andi.w	#$E0,d2			; = 発音管理番号×20H
;		lsl.w	#4,d2			; = 発音管理番号×200H
;		move.w	d2,_tmp_kanri(a6)	; = 000,200,400,..
;		andi.w	#$1F,d1			; = MIDI ch#
;		cmpi.w	#$10,d1
;		bcc.w	er_MIDI2_in		; jump if MIDI2 input
;
;		move.w	d1,d2			;
;		lsl.w	#5,d2			; MIDI ch * knr_unit
;		add.w	_tmp_kanri(a6),d2	; = 発音管理番号×200H
;		move.w	d2,knr_kanri_ofst(a6)	;
;
;		move.w	d1,_tmp_MIDI_ch(a6)	; word	; $0000 ～ $001F
;		move.b	(a1)+,d2		; 2nd Message ( Note# )
;		move.b	(a1),d3			; 3rd Message ( Velo )
;		;-------------------------------;
;		andi.w	#7,d0			; 00000xxx
;		lsl.w	#2,d0			; 000xxx00
;
;		jmp	MIDI_JPTB(pc,d0.w)
;MIDI_JPTB:	jmp	Note_off(pc)	; 8n ; note off
;		jmp	Note_on(pc)	; 9n : note on
;		jmp	er_1C(pc)	; An : polyphonic key pressure
;		jmp	CTRL_CHG(pc)	; Bn : control change
;		jmp	PRG_chg(pc)	; Cn : program change
;		jmp	er_1D(pc)	; Dn : channel pressure
;		jmp	MIDI_En(pc)	; En : pitch bend change
;		jmp	er_1E(pc)	; Fn :


			.public		MIDI_ctrl
MIDI_ctrl:
		addq.b	#1,_MIDI_RCV_RDPT(a6)		; read point of MIDI receive buffer.

		movea.l	#midi_receive_buffer,a1
		add.w	d0,d0				; bit 31-7 are already cleared before call this routine.
		add.w	d0,d0
		adda.w	d0,a1

			.public		MIDI_ctrl_pt
MIDI_ctrl_pt:
		bsr.w	set_MIDI_OUT_BF			; SCSP-MIDI OUT

		move.b	(a1)+,d0			; Priority(7-3) & コマンド(2-0)
		move.b	(a1)+,d1			; bit 7-5 is management number(0-7), bit 3-0 is midi channel(0-15).
		move.b	d1,d2
		andi.w	#$00e0,d2			; already, d2 is management number*0x20.
		add.w	d2,d2
		add.w	d2,d2
		add.w	d2,d2
		add.w	d2,d2				; d2 = management number(0-7)*0x200.

		move.w	d2,_tmp_kanri(a6)		; = 000,200,400,..
		andi.w	#$001f,d1			; = MIDI ch#
		cmpi.w	#$0010,d1
	;;	bcc.w	er_MIDI2_in			; jump if MIDI2 input
		bcc.s	?end_of_midi_interpriter	; midi channel, 0x10 to 0x1f are not available on ver-1.41 or later.

		move.w	d1,d2				;
		lsl.w	#5,d2				; MIDI channel number*0x20
		add.w	_tmp_kanri(a6),d2		; = 発音管理番号×200H
		move.w	d2,knr_kanri_ofst(a6)		;

		move.w	d1,_tmp_MIDI_ch(a6)		; word	; $0000 ～ $001F
		move.b	(a1)+,d2			; 2nd Message ( Note# )
		move.b	(a1),d3				; 3rd Message ( Velo )

		andi.w	#$0007,d0
		add.w	d0,d0
		movea.w	?jump_table(pc,d0.w),a1
		jsr	(a1)

	?end_of_midi_interpriter:
		rts

	?jump_table:
		dc.w	Note_off			; 8n ; note off
		dc.w	Note_on				; 9n : note on
		dc.w	er_1C				; An : polyphonic key pressure
		dc.w	CTRL_CHG			; Bn : control change
		dc.w	PRG_chg				; Cn : program change
		dc.w	er_1D				; Dn : channel pressure
		dc.w	MIDI_En				; En : pitch bend change
		dc.w	er_1E				; Fn :

;		}

;-----------------------------------------------------------------------;
;		68K CPU 処理 MIDI の バッファリング			;
; destroy d0/d1/d4							;
;	  a2								;
;-----------------------------------------------------------------------;
		global	set_MIDI_OUT_BF	
set_MIDI_OUT_BF:
		lea	_MIDI_OUT_BF(a6),a2	;
		move.w	_MIDI_OUT_WRPT(a6),d4	; byte
		andi.w	#$3FF,d4		;
		move.b	(a1),d0			; Priority(7-3) & コマンド(2-0)
		lsl.b	#4,d0			;
		ori.b	#$80,d0			;
		move.b	1(a1),d1		; 発音管理番号 ＆ MIDI ch#
		andi.b	#$0F,d1			;
		or.b	d1,d0			;
		move.b	d0,(a2,d4.w)		; MIDI 1st
		addq.w	#1,d4			;
		andi.w	#$3FF,d4		;
		cmpi.b	#$C0,d0			;
		bcs.w	MIDI_out_st_3		; jump if 3byte out
		cmpi.b	#$E0,d0			;
		bcc.w	MIDI_out_st_3		; jump if 3byte out
		move.b	2(a1),(a2,d4.w)		; MIDI 2nd
		bra.w	MIDI_out_st_2		; jump if 2byte out
MIDI_out_st_3:	move.b	2(a1),(a2,d4.w)		; MIDI 2nd
		addq.w	#1,d4			;
		andi.w	#$3FF,d4		;
		move.b	3(a1),(a2,d4.w)		; MIDI 3rd
MIDI_out_st_2:	addq.w	#1,d4			;
		andi.w	#$3FF,d4		;
		move.w	d4,_MIDI_OUT_WRPT(a6)	; byte
		rts
;-----------------------------------------------------------------------;
er_MIDI2_in:	bset.b	#ERRa_9,Mem_DRVERR_FLG+0	; MIDI ch 10H～1FH input
		rts
er_1C:		bset.b	#ERRa_2,Mem_DRVERR_FLG+1	; MIDI Polyphonic Key pressure
		rts
er_1D:		bset.b	#ERRa_3,Mem_DRVERR_FLG+1	; MIDI channel pressure
		rts
er_1E:		bset.b	#ERRa_4,Mem_DRVERR_FLG+1	; MIDI F0H～FFH input
		rts
;************************************************************************
;【 機 能 】 各々のＭＩＤＩコントロールチェンジ[$Bn,$cc,$xx]番号へ分岐	*
;	     させる。未定義のコントロール番号に対してはエラー処理（プロ	*
;	     グラム開発用）または無処理（実機用）とする。		*
;【 入 力 】a6   : work RAM top						*
;	    d1.w : MIDI ch#            	( 00 ～ 1FH )			*
;	    d2.b : MIDI Control Number 	( 00 ～ 7FH )			*
;           d3.b : Parameter 		( 00 ～ 7FH )			*
;【 出 力 】nothing							*
;【destroy】d1.w							*
;【 hold  】a5/a6						94/07/28*
;************************************************************************

; A.Miyazawa	{

;		global	CTRL_CHG
;CTRL_CHG:	move.w	d2,d4
;		andi.w	#$7F,d2			;
;		add.w	d2,d2			;
;		add.w	d2,d2			;
;		jmp	MIDI_Bn_TB(pc,d2.w)	;
;MIDI_Bn_TB:
;Bn_00_0F:	jmp	_______(pc)	; $00
;		jmp	CTRL_01(pc)	; $01 音源ハード Modulation Wheel
;		jmp	_______(pc)	; $02 Map change
;		jmp	_______(pc)	; $03
;		jmp	_______(pc)	; $04 不特定（フットタイプ操作子）
;		jmp	_______(pc)	; $05 Portament time
;		jmp	_______(pc)	; $06 data entry MSB ( RPN/NRPN )
;		jmp	CTRL_07(pc)	; $07 Main Volume
;		jmp	_______(pc)	; $08 Balance Control
;		jmp	_______(pc)	; $09
;		jmp	CTRL_0A(pc)	; $0A Direct Pan
;		jmp	CTRL_0B(pc)	; $0B Expression
;		jmp	_______(pc)	; $0C
;		jmp	_______(pc)	; $0D
;		jmp	_______(pc)	; $0E
;		jmp	_______(pc)	; $0F
;		jmp	CTRL_10(pc)	; $10 Mixer change
;		jmp	CTRL_11(pc)	; $11 Effect Pan
;	if	ENGN
;		jmp	CTRL_12(pc)	; $12 不特定（汎用操作子３）
;		jmp	CTRL_13(pc)	; $13 不特定（汎用操作子４）
;	else
;		jmp	_______(pc)	; $12 不特定（汎用操作子３）
;		jmp	_______(pc)	; $13 不特定（汎用操作子４）
;	endif
;		jmp	_______(pc)	; $14
;		jmp	_______(pc)	; $15
;		jmp	_______(pc)	; $16
;		jmp	_______(pc)	; $17
;		jmp	_______(pc)	; $18
;		jmp	_______(pc)	; $19
;		jmp	_______(pc)	; $1A
;		jmp	_______(pc)	; $1B
;		jmp	_______(pc)	; $1C
;		jmp	_______(pc)	; $1D
;		jmp	_______(pc)	; $1E
;		jmp	_______(pc)	; $1F Sequencer loop mode
;		jmp	CTRL_20(pc)	; $20 Tone BANK change
;		jmp	_______(pc)	; $21
;		jmp	_______(pc)	; $22
;		jmp	_______(pc)	; $23
;		jmp	_______(pc)	; $24
;		jmp	_______(pc)	; $25
;		jmp	_______(pc)	; $26 data entry LSB ( RPN/NRPN )
;		jmp	_______(pc)	; $27
;		jmp	_______(pc)	; $28
;		jmp	_______(pc)	; $29
;		jmp	_______(pc)	; $2A
;		jmp	_______(pc)	; $2B
;		jmp	_______(pc)	; $2C
;		jmp	_______(pc)	; $2D
;		jmp	_______(pc)	; $2E
;		jmp	_______(pc)	; $2F
;		jmp	_______(pc)	; $30
;		jmp	_______(pc)	; $31
;		jmp	_______(pc)	; $32
;		jmp	_______(pc)	; $33
;		jmp	_______(pc)	; $34
;		jmp	_______(pc)	; $35
;		jmp	_______(pc)	; $36
;		jmp	_______(pc)	; $37
;		jmp	_______(pc)	; $38
;		jmp	_______(pc)	; $39
;		jmp	_______(pc)	; $3A
;		jmp	_______(pc)	; $3B
;		jmp	_______(pc)	; $3C
;		jmp	_______(pc)	; $3D
;		jmp	_______(pc)	; $3E
;		jmp	_______(pc)	; $3F
;		jmp	CTRL_40(pc)	; $40 Damper
;		jmp	_______(pc)	; $41 Portament
;		jmp	_______(pc)	; $42 Sosutenute(Code Hold)
;		jmp	_______(pc)	; $43 Soft Pedal
;		jmp	_______(pc)	; $44
;		jmp	_______(pc)	; $45 Hold2(Freeze)
;		jmp	_______(pc)	; $46 未定義
;		jmp	CTRL_47(pc)	; $47 Effect return
;		jmp	_______(pc)	; $48
;		jmp	_______(pc)	; $49
;		jmp	_______(pc)	; $4A
;		jmp	_______(pc)	; $4B
;		jmp	_______(pc)	; $4C
;		jmp	_______(pc)	; $4D
;		jmp	_______(pc)	; $4E
;		jmp	_______(pc)	; $4F
;		jmp	CTRL_50(pc)	; $50 Q sound position
;		jmp	CTRL_51(pc)	; $51 3D 
;		jmp	CTRL_52(pc)	; $52 3D horizontal position
;		jmp	CTRL_53(pc)	; $53 3D vertical position
;		jmp	_______(pc)	; $54
;		jmp	_______(pc)	; $55
;		jmp	_______(pc)	; $56
;		jmp	_______(pc)	; $57
;		jmp	_______(pc)	; $58
;		jmp	_______(pc)	; $59
;		jmp	_______(pc)	; $5A
;		jmp	CTRL_5B(pc)	; $5B Effect change
;		jmp	_______(pc)	; $5C Tremono depth
;		jmp	_______(pc)	; $5D Chorus depth
;		jmp	_______(pc)	; $5E Seleste depth
;		jmp	_______(pc)	; $5F fazer depth
;		jmp	_______(pc)	; $60 data increment
;		jmp	_______(pc)	; $61 data decrement
;		jmp	_______(pc)	; $62 NRPN LSB
;		jmp	_______(pc)	; $63 NRPN MSB
;		jmp	_______(pc)	; $64 RPN  LSB
;		jmp	_______(pc)	; $65 PRN  MSB
;		jmp	_______(pc)	; $66
;		jmp	_______(pc)	; $67
;		jmp	_______(pc)	; $68
;		jmp	_______(pc)	; $69
;		jmp	_______(pc)	; $6A
;		jmp	_______(pc)	; $6B
;		jmp	_______(pc)	; $6C
;		jmp	_______(pc)	; $6D
;		jmp	_______(pc)	; $6E
;		jmp	_______(pc)	; $6F
;		jmp	_______(pc)	; $70
;		jmp	_______(pc)	; $71
;		jmp	_______(pc)	; $72
;		jmp	_______(pc)	; $73
;		jmp	_______(pc)	; $74
;		jmp	_______(pc)	; $75
;		jmp	_______(pc)	; $76
;		jmp	_______(pc)	; $77
;		jmp	CTRL_78(pc)	; $78 ALL SOUND OFF
;		jmp	_______(pc)	; $79 RES ALL CTRLER
;		jmp	_______(pc)	; $7A local control
;		jmp	CTRL_7B(pc)	; $7B all note off
;		jmp	_______(pc)	; $7C OMNI OFF
;		jmp	_______(pc)	; $7D omni mode on
;		jmp	_______(pc)	; $7E mono mode
;		jmp	_______(pc)	; $7F Play mode
;
;_______:	bset.b	#ERRb14,Mem_err_bit+2	; 不正 Control change# input
;		rts
;

			.public		CTRL_CHG
CTRL_CHG:
		move.w	d2,d4
		andi.w	#$007f,d2
	;	add.w	d2,d2
		add.w	d2,d2
		movea.w	MIDI_Bn_TB(pc,d2.w),a0
		jmp	(a0)
MIDI_Bn_TB:
Bn_00_0F:	dc.w	_______		; $00
		dc.w	CTRL_01		; $01 音源ハード Modulation Wheel
		dc.w	CTRL_0B		; $02 Map change
		dc.w	_______		; $03
		dc.w	_______		; $04 不特定（フットタイプ操作子）
		dc.w	_______		; $05 Portament time
		dc.w	_______		; $06 data entry MSB ( RPN/NRPN )
		dc.w	CTRL_07		; $07 Main Volume
		dc.w	_______		; $08 Balance Control
		dc.w	_______		; $09
		dc.w	CTRL_0A		; $0A Direct Pan
		dc.w	CTRL_0B		; $0B Expression
		dc.w	_______		; $0C
		dc.w	_______		; $0D
		dc.w	_______		; $0E
		dc.w	_______		; $0F
		dc.w	CTRL_10		; $10 Mixer change
		dc.w	CTRL_11		; $11 Effect Pan

			.if ENGN

		dc.w	CTRL_12		; $12 不特定（汎用操作子３）
		dc.w	CTRL_13		; $13 不特定（汎用操作子４）

			.else

		dc.w	_______		; $12 不特定（汎用操作子３）
		dc.w	_______		; $13 不特定（汎用操作子４）

			.endif

		dc.w	_______		; $14
		dc.w	_______		; $15
		dc.w	_______		; $16
		dc.w	_______		; $17
		dc.w	_______		; $18
		dc.w	_______		; $19
		dc.w	_______		; $1A
		dc.w	_______		; $1B
		dc.w	_______		; $1C
		dc.w	_______		; $1D
		dc.w	_______		; $1E
		dc.w	_______		; $1F Sequencer loop mode
		dc.w	CTRL_20		; $20 Tone BANK change
		dc.w	_______		; $21
		dc.w	_______		; $22
		dc.w	_______		; $23
		dc.w	_______		; $24
		dc.w	_______		; $25
		dc.w	_______		; $26 data entry LSB ( RPN/NRPN )
		dc.w	_______		; $27
		dc.w	_______		; $28
		dc.w	_______		; $29
		dc.w	_______		; $2A
		dc.w	_______		; $2B
		dc.w	_______		; $2C
		dc.w	_______		; $2D
		dc.w	_______		; $2E
		dc.w	_______		; $2F
		dc.w	_______		; $30
		dc.w	_______		; $31
		dc.w	_______		; $32
		dc.w	_______		; $33
		dc.w	_______		; $34
		dc.w	_______		; $35
		dc.w	_______		; $36
		dc.w	_______		; $37
		dc.w	_______		; $38
		dc.w	_______		; $39
		dc.w	_______		; $3A
		dc.w	_______		; $3B
		dc.w	_______		; $3C
		dc.w	_______		; $3D
		dc.w	_______		; $3E
		dc.w	_______		; $3F
		dc.w	CTRL_40		; $40 Damper
		dc.w	_______		; $41 Portament
		dc.w	_______		; $42 Sosutenute(Code Hold)
		dc.w	_______		; $43 Soft Pedal
		dc.w	_______		; $44
		dc.w	_______		; $45 Hold2(Freeze)
		dc.w	CTRL_11		; $46 Effect Pan
		dc.w	CTRL_47		; $47 Effect return
		dc.w	_______		; $48
		dc.w	_______		; $49
		dc.w	_______		; $4A
		dc.w	_______		; $4B
		dc.w	_______		; $4C
		dc.w	_______		; $4D
		dc.w	_______		; $4E
		dc.w	_______		; $4F
		dc.w	CTRL_50		; $50 Q sound position
		dc.w	CTRL_51		; $51 3D 
		dc.w	CTRL_52		; $52 3D horizontal position
		dc.w	CTRL_53		; $53 3D vertical position
		dc.w	_______		; $54
		dc.w	_______		; $55
		dc.w	_______		; $56
		dc.w	_______		; $57
		dc.w	_______		; $58
		dc.w	_______		; $59
		dc.w	_______		; $5A
		dc.w	CTRL_5B		; $5B Effect change
		dc.w	_______		; $5C Tremono depth
		dc.w	_______		; $5D Chorus depth
		dc.w	_______		; $5E Seleste depth
		dc.w	_______		; $5F fazer depth
		dc.w	_______		; $60 data increment
		dc.w	_______		; $61 data decrement
		dc.w	_______		; $62 NRPN LSB
		dc.w	_______		; $63 NRPN MSB
		dc.w	_______		; $64 RPN  LSB
		dc.w	_______		; $65 PRN  MSB
		dc.w	_______		; $66
		dc.w	_______		; $67
		dc.w	_______		; $68
		dc.w	_______		; $69
		dc.w	_______		; $6A
		dc.w	_______		; $6B
		dc.w	_______		; $6C
		dc.w	_______		; $6D
		dc.w	_______		; $6E
		dc.w	_______		; $6F
		dc.w	_______		; $70
		dc.w	_______		; $71
		dc.w	_______		; $72
		dc.w	_______		; $73
		dc.w	_______		; $74
		dc.w	_______		; $75
		dc.w	_______		; $76
		dc.w	_______		; $77
		dc.w	CTRL_78		; $78 ALL SOUND OFF
		dc.w	_______		; $79 RES ALL CTRLER
		dc.w	_______		; $7A local control
		dc.w	CTRL_7B		; $7B all note off
		dc.w	_______		; $7C OMNI OFF
		dc.w	_______		; $7D omni mode on
		dc.w	_______		; $7E mono mode
		dc.w	_______		; $7F Play mode

_______:	bset.b	#ERRb14,Mem_err_bit+2	; 不正 Control change# input
		rts

;		}

;************************************************************************
;【機能】 ＭＩＤＩコントロールチェンジ[$Bn,$11,$xx]制御。		*
;		<<  Effect Pan チェンジ >>				*
;【入力】d1.w : EFREG# ( 本来は MIDI ch# : 0～F )			*
;	 d3.b : Parameter					94/07/26*
;************************************************************************
		global	CTRL_11
CTRL_11:
;@		cmpi.b	#$12,d1
;@		bcc	CTRL_11_ret

		andi.b	#$7F,d3			; 0xxx xxxxB : 0(L) ～ 7FH(R)
		lsr.b	#2,d3			; 
		subi.b	#$10,d3			;
		bcc.s	CTRL_11_2		;
		not.b	d3			;
		addi.b	#$10,d3			; 1FH(L)～10H(C)00H～0FH(R)
CTRL_11_2:	;-------------------------------; d3.b = EFPAN ( 0 ～ 1FH )
		move.b	SND_OUT_ST(a6),d2	; MONO/STEREO status
		bpl.s	CTRL_11_ST		; jump if not MONO mode
		andi.b	#$E0,d3			;
CTRL_11_ST:	move.w	d1,d2
		addi.w	#mixer_wk_SCSP,d2
		move.b	(a6,d2.w),d0
		andi.b	#$E0,d0
		or.b	d0,d3
		move.b	d3,(a6,d2.w)

		lsl.w	#5,d1			; SCSP_slot_unit * MIDI ch#
		move.b	d3,SCSP_EFSDLPN(a5,d1.w)
CTRL_11_ret:	rts
;************************************************************************
;【機能】 ＭＩＤＩコントロールチェンジ[$Bn,$46,$xx]制御。		*
;		<<  Ｅffect Return  >>					*
;【入力】d1.w : EFREG# ( 本来は MIDI ch# : $00～$1F )			*
;	 d3.b : Parameter					94/07/26*
;************************************************************************
		global	CTRL_47
CTRL_47:
		cmpi.b	#$12,d1
		bcc	CTRL_47_ret

		andi.b	#$70,d3			; 00H(Min) ～ 7FH(Max)
		add.b	d3,d3			; 00H(Min) ～ E0H(Max)

		move.w	d1,d2
		addi.w	#mixer_wk_SCSP,d2
		move.b	(a6,d2.w),d0
		andi.b	#$1F,d0
		or.b	d0,d3
		move.b	d3,(a6,d2.w)

		lsl.w	#5,d1			; 20H * MIDI ch#
		move.b	d3,SCSP_EFSDLPN(a5,d1.w)
CTRL_47_ret:	rts
;@;************************************************************************
;@;【機能】 ＭＩＤＩコントロールチェンジ[$Bn,$00,$xx]制御。		*
;@;		<< Map change >>					*
;@;【入力】d3.b : Map# 00～7F						*
;@;	 d1.w : MIDI ch
;@;************************************************************************
;@		global	CTRL_02
;@CTRL_02:	moveq	#0,d0
;@		move.b	d3,d0		; ready d0.w
;@	external	MAP_chg
;@		jmp	MAP_chg(pc)	; jump and return
;************************************************************************
;【 機 能 】 ＭＩＤＩコントロールチェンジ[$Bn,$01,$xx]制御。		*
;		<< 音源ハード Modulation_Wheel >>			*
;************************************************************************
		global	CTRL_01
CTRL_01:	move.w	_tmp_kanri(a6),d2	; = 000,200,400,..,E00
		add.b	d3,d3			; $00～$3F:off / $40～$7F:on
		andi.b	#$E0,d3			; = xxx0 0000B : [PLFOS]

		moveq	#slot_size-1,d7
		clr.w	d4
		lea	slot_work(a6),a0
CTRL_01_lp:	cmp.b	sl_MIDI(a0,d4.w),d1	; MIDIch# equal ?
		bne.s	CTRL_01_1		; jump if no
		move.b	PSPN(a4,d4.w),d0	; 95/08/02 PCM Stream playing ?
		bmi.w	CTRL_01_1		; 95/08/02 jp if PCM Stream playing 
;@		cmp.w	_sl_kanri(a4,d4.w),d2	; 管理番号 equal ?
		cmp.w	_sl_kanri(a0,d4.w),d2	; 管理番号 equal ?
		bne.s	CTRL_01_1		; jump if no
		movea.l	sl_layer_adr(a0,d4.w),a1
		move.b	LY_SISD(a1),d0		; Mod-Wheel execute ?
		bpl.s	CTRL_01_1		; jump if no
		move.b	LY_LFOS(a1),d5		;
		move.b	d3,d3			;
		bmi.s	CTRL_01_2		; jump if velo = $40 ～ $7F
		andi.b	#$18,d5			; LFO sens <-- 0
CTRL_01_2:	lsr.w	#1,d4			; = $00,$20,$40,...,$3E0
		move.b	d5,SCSP_PLFOS(a5,d4.w)	; [PLFOS] & [ALFOWS] & [ALFOS]
		add.w	d4,d4			; = $00,$40,$80,...,$7C0
CTRL_01_1:	addi.w	#slot_wk_unit,d4
		dbra	d7,CTRL_01_lp
		rts
;************************************************************************
;【 機 能 】 ＭＩＤＩコントロールチェンジ[$Bn,$78,$nn]制御。		*
;		<< all sound off >>					*
;	 該当管理番号&該当チャンネルの強制的な key-off & rerease off 	*
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
;【 機 能 】 ＭＩＤＩコントロールチェンジ[$Bn,$7B,$nn]制御。		*
;		<< all note off >>					*
;	 該当管理番号&該当チャンネルの強制的な key-off（リリースは有効）*
; $nn = 40H ---> 該当管理番号曲の全ての MIDI ch に対して実行		*
;************************************************************************
		global	CTRL_78,CTRL_7B
CTRL_7B:	moveq	#1,d5			; set Control# = 7BH mode
		bra.s	CTRL_7B_1
CTRL_78:	moveq	#0,d5			; set Control# = 78H mode
CTRL_7B_1:
		rts

		lea	bs_PWKTP,a6		; 68K Prg work top address
		lea	IO_SCSP,a5		; 固定
		add.b	d3,d3			; d3 = Parameter

		lea	_KEYHISTB(a6),a0	;
		moveq	#slot_size,d7		; clear 
		sub.w	off_slot_cnt(a6),d7	; = key-on slot数
		beq	CTRL_78_exit		; jump if key-on slot nothing

		subq.w	#1,d7			; loop size
		move.w	HIS_off_pt(a6),d0	;
CTRL_78_lp:	andi.w	#HOPM,d0		; 0,2,4,...,3EH
		move.w	(a0,d0.w),d4		; = $00,$40,$80,$C0,$100,..
		andi.w	#KHMSK,d4		; $7C0

		move.w	_sl_kanri(a4,d4.w),d6	;
		cmp.w	_tmp_kanri(a6),d6	; 発音管理番号 equal ?
		bne	CTRL_78_next		; jump if not equal
		move.b	PSPN(a4,d4.w),d6	; PCM Stream playing ?
		bmi.w	CTRL_78_next		; jump if PCM Stream playing 
	if	ENGN
		move.b	sl_flag1(a4,d4.w),d6	; Engine ?
		bmi.w	CTRL_78_next		; jump if Yes
	endif
		move.b	d3,d3
		bmi.s	CTRL_78_2
		cmp.b	sl_MIDI(a4,d4.w),d1	; MIDI ch# equal ?
		bne	CTRL_78_next		; jump if not equal
CTRL_78_2:
		bclr.b	#flg_non,sl_flag2(a4,d4.w)	; set Note-off中 mode
		move.b	sl_MIDI(a4,d4.w),d6	; d1 = MIDIch#
		andi.w	#$0F,d6			;
		lsl.w	#5,d6			; ×knr_unit
		add.w	_tmp_kanri(a6),d6	; + 000,200,400,..
		bclr.b	#knr_DMPR,knr_MIDI_flg(a6,d6.w)	; set Damper off mode
		bclr.b	#flg_KON,sl_flag2(a4,d4.w)	; set key-off中 mode
		addq.w	#1,off_slot_cnt(a6)	; = key off slot数 + 1
		bclr.b	#PEON_flg,sl_flag1(a4,d4.w)	; PEG off
;@		jsr	PEG_off(pc)		;

;		<<<< Key-off 実行 >>>>

		lsr.w	#1,d4			;
		move.b	d5,d5			;
		bne.s	CTRL_78_3		; jump if BnH,7BH,nnH
		move.b	#$FF,SCSP_FH_RR(a5,d4.w)	; rerease off
CTRL_78_3:	move.b	SCSP_KXKB(a5,d4.w),d2	; @0001
		andi.b	#%00000111,d2		; clear KYONEX
		move.b	d2,SCSP_KXKB(a5,d4.w)	; write KYONEX & KYONB
		add.w	d4,d4			;

;		<<<< KEYHISTB 更新 >>>>

		swap	d7		;+	;
		move.w	HIS_off_pt(a6),d5	;
		andi.w	#HOPM,d5		; 0,2,4,...,3EH
		move.w	d0,d6			;
OF_1_lp:	move.w	d6,d7			;
		cmp.w	d6,d5			;
		beq.s	OF_1			;
		move.w	(a0,d7.w),d4		;
		subq.w	#2,d6			;
		andi.w	#HOPM,d6		; 0,2,4,...,3EH
		move.w	(a0,d6.w),(a0,d7.w)	;
		move.w	d4,(a0,d6.w)		;
		bra.s	OF_1_lp			;
OF_1:		addq.w	#2,HIS_off_pt(a6)	;
		swap	d7		;+	;

CTRL_78_next:	addq.w	#2,d0
		dbra	d7,CTRL_78_lp		;

		move.b	(a5),d0			;
		ori.b	#%00010000,d0		; set KYONEX
		move.b	d0,(a5)			; write KYONEX & KYONB
CTRL_78_exit:	rts
;************************************************************************
;【機能】 ＭＩＤＩコントロールチェンジ[$Bn,$07,$xx]制御。		*
;	  発音中の同一発音管理番号,同一MIDI-chに対して音量を変更。	*
;	  以後の同一発音管理番号,同一MIDI-chに対してはこの音量倍率で換算*
;【入力】a5   : FH1005 top						*
;	 d1.w : MIDI ch# ( 0 ～ 1F )					*
;        d3.b : Parameter 00(-∞dB)～7FH(-0dB)			94/07/26*
;************************************************************************

; A.Miyazawa	{

;		global	CTRL_0B
;CTRL_0B:	move.w	d1,d0
;		lsl.w	#5,d0			; = MIDI ch# * knr_unit
;		move.w	_tmp_kanri(a6),d2	; = 000,200,400,..
;		add.w	d2,d0			; + 発音管理番号×200H
;		andi.w	#$7F,d3			;
;		addq.w	#1,d3			; = 1～80H
;		move.b	d3,knr_MIDI_11(a6,d0.w)	;
;		moveq	#0,d4			;
;		move.b	knr_MIDI_7(a6,d0.w),d4	; = MIDI main volume (1～80H)
;		bra.w	CTRL_7_11
;		global	CTRL_07
;CTRL_07:	move.w	d1,d0
;		lsl.w	#5,d0			; = MIDI ch# * knr_unit
;		move.w	_tmp_kanri(a6),d2	; = 000,200,400,..
;		add.w	d2,d0			; + 発音管理番号×200H
;		andi.w	#$7F,d3			;
;		addq.w	#1,d3			; = 1～80H
;		move.b	d3,knr_MIDI_7(a6,d0.w)	;
;		moveq	#0,d4			;
;		move.b	knr_MIDI_11(a6,d0.w),d4	; = MIDI expression (1～80H)
;
;CTRL_7_11:	mulu	d4,d3			;  = 1～4000H
;		subq.w	#1,d3			;  = 0～3FFFH
;		lsr.w	#7,d3			;  = 0～7FH
;		addq.w	#1,d3			;  = 1～80H
;		move.b	d3,knr_MIDI_Volume(a6,d0.w)	; = 1～80H
;		;-------------------------------;
;		moveq	#slot_size-1,d7		; loop size
;		moveq	#0,d4			;
;		lea	slot_work(a6),a0	;
;CTRL_07_lp:	cmp.w	_sl_kanri(a0,d4.w),d2	;
;		bne.s	CTRL_07_1		;
;		cmp.b	sl_MIDI(a0,d4.w),d1	;
;		bne.s	CTRL_07_1		;
;		; PCM Stream 再生中にBGMを再生すると PCM Stream 再生音量が
;		; 影響を受けてしまう。
;		btst.b	#PCM_flg,PSPN(a0,d4.w)	; 10/21	PCM stream playing ?
;		bne.s	CTRL_07_1		; 10/21	jump if yes
;	if	ENGN
;		btst.b	#ENGN_flg,sl_flag1(a0,d4.w)	; Engine ?
;		bne.s	CTRL_07_1			; jump if yes
;	endif
;		btst.b	#flg_FMCR,sl_flag2(a0,d4.w)
;		beq.s	CTRL_07_1		;
;		moveq	#0,d5			; clear
;		move.b	sl_VL(a0,d4.w),d5	; 1 ～ 80H(Max)
;		; d5.w[slot_volume(1～80H)] × d3.w[midi_volume(1～80H)]
;		mulu	d3,d5			; = 1～4000H
;		subq.w	#1,d5			; = 0～3FFFH
;		lsr.w	#6,d5			; = 0～FFH(Max)
;		not.b	d5			; = FF～0(Max)
;		lsr.w	#1,d4			; d4 = $000,$020,$040,..,$3E0
;		move.b	d5,SCSP_TLVL(a5,d4.w)	;
;		add.w	d4,d4			; d4 = $000,$040,$080,..,$7C0
;		;-------------------------------;
;CTRL_07_1:	addi.w	#slot_wk_unit,d4	; +$40
;		dbra	d7,CTRL_07_lp
;		rts

			.public		CTRL_0B
CTRL_0B:
		andi.w	#$007f,d3
		move.w	_tmp_kanri(a6),d2		; d2= management number * 0x200
		move.w	d1,d0				; d1=midi channel number
		lsl.w	#5,d0
		add.w	d2,d0				; d0= d2+midi channel * 0x20
		move.w	d3,midi_expression(a6,d0.w)
		bra.s	scsp_access

			.public		CTRL_07
CTRL_07:
		andi.w	#$007f,d3
		move.w	_tmp_kanri(a6),d2		; d2= management number * 0x200
		move.w	d1,d0				; d1=midi channel number
		lsl.w	#5,d0
		add.w	d2,d0				; d0= d2+midi channel * 0x20
		move.w	d3,midi_volume(a6,d0.w)
	;	bra.s	scsp_access

scsp_access:
		move.w	midi_expression(a6,d0.w),d3
		move.w	midi_volume(a6,d0.w),d4
		mulu	d4,d3				;  d3,d2=(0 to 0x7f)
		lsr.w	#7,d3
		move.w	d3,midi_master_volume(a6,d0.w)

		moveq	#slot_size-1,d7
		moveq	#0,d4
		lea	slot_work(a6),a0

	?slot_loop:
		cmp.w	_sl_kanri(a0,d4.w),d2		; check management number
		bne.s	?function_false

		cmp.b	sl_MIDI(a0,d4.w),d1		; check midi channel
		bne.s	?function_false

		btst.b	#PCM_flg,PSPN(a0,d4.w)		; check PCM stream
		bne.s	?function_false

			.if ENGN

		btst.b	#ENGN_flg,sl_flag1(a0,d4.w)	; Engine ?
		bne.s	?function_false			; jump if yes

			.endif

		btst.b	#flg_FMCR,sl_flag2(a0,d4.w)
		beq.s	?function_false


		movem.l	d2/a1,-(sp)

		move.w	slot_velocity(a0,d4.w),d2
		move.w	midi_master_volume(a6,d0.w),d3
		mulu	d2,d3				; 0 to 0x7f
		lsr.w	#6,d3				; 8bit
		move.w	d3,total_volume(a6,d0.w)

		movea.l	management(a6,d0.w),a1
		move.w	sequence_volume(a1),d2
		eori.b	#$80,d2
		ext.w	d2
		add.w	d2,d3
		bmi.s	?overflow_underflow

		cmpi.w	#$0100,d3
		bcc.s	?overflow_underflow

		bra.s	?result

	?overflow_underflow:

		tst.w	d3
		spl.b	d3
	?result:
		not.b	d3

		movem.l	(sp)+,d2/a1

		lsr.w	#1,d4				; d4 = $000,$020,$040,..,$3E0
		move.b	d3,SCSP_TLVL(a5,d4.w)		;
		add.w	d4,d4				; d4 = $000,$040,$080,..,$7C0

	?function_false:
		addi.w	#slot_wk_unit,d4	; +$40
		dbra	d7,?slot_loop

		rts

;		}

;************************************************************************
;【機能】 ＭＩＤＩコントロールチェンジ[$Bn,$0A,$xx]制御。		*
;	  発音中の同一発音管理番号,同一MIDI-chに対して Pan を変更。	*
;	  以後の同一発音管理番号,同一MIDI-chに対してはこの Pan potに従う*
;	  （この Pan は Direct成分であり、Effect成分ではない。）	*
;【入力】a5   : FH1005 top						*
;	 d1.w : MIDI ch# ( 0 ～ 1F )					*
;        d3.b : Parameter 00H(left)～40H(center)～7FH(right)	94/07/26*
;************************************************************************
;		global	CTRL_0A
;CTRL_0A:	andi.b	#$7F,d3			; 0(L) ～ 40H(C) ～ 7FH(R)
;		lsr.b	#2,d3			;	    ↓
;		subi.b	#$10,d3			;	    ↓
;		bcc.s	CTRL_0A_0		;	    ↓
;		not.b	d3			;	    ↓
;		addi.b	#$10,d3			; 1FH(L)～10H(C)00H～0FH(R)
;CTRL_0A_0:	;-------------------------------; d3.b = DIPAN ( 0 ～ 1FH )
;		move.w	knr_kanri_ofst(a6),d0	;
;		bset.b	#7,knr_MIDI_PAN(a6,d0.w)	; set Layer PAN off
;		move.b	knr_MIDI_PAN(a6,d0.w),d4	;
;		btst	#6,d4			; SEQ PAN on ?
;		beq.s	CTRL_0A_2		; jump if off
;		btst.b	#7,SND_OUT_ST(a6)	; MONO/STEREO status
;		bne.s	CTRL_0A_mono		; jump if MONO mode
;		rts				; return if STEREO mode
;		; <<< SEQ PAN off >>>
;CTRL_0A_2:	btst.b	#7,SND_OUT_ST(a6)	; MONO/STEREO status
;		bne.s	CTRL_0A_mono		; jump if MONO mode
;		; <<< SEQ PAN off & STEREO mode >>>
;		ori.b	#$80,d3			; set layer PAN off
;		move.b	d3,knr_MIDI_PAN(a6,d0.w)	;
;		andi.b	#$1F,d3			;
;		bra.s	CTRL_0A_ST		; jump STEREO mode
;		;-------------------------------;
;CTRL_0A_mono:	clr.w	d3			; --> Center
;		;-------------------------------;
;		; 発音中スロットの同一 MIDI ch	;
;		; の全てに対して PAN を更新	;
;		;-------------------------------;
;CTRL_0A_ST:	moveq	#slot_size-1,d7		; loop size
;		moveq	#0,d4			;
;		lea	slot_work(a6),a0	;
;CTRL_0A_lp:	cmp.b	sl_MIDI(a0,d4.w),d1	;
;		bne	CTRL_0A_1		; jump if not equal MIDI ch#
;		cmp.w	_sl_kanri(a0,d4.w),d0	;
;		bne	CTRL_0A_1		; jump if not equal 管理番号
;		; - - - - - - - - - - - - - - - -
;		btst.b	#PCM_flg,PSPN(a0,d4.w)	; 95/06/28 PCM stream playing ?
;		bne.w	CTRL_0A_1		; jump if yes
;	if	ENGN
;		btst.b	#ENGN_flg,sl_flag1(a0,d4.w)	; Engine ?
;		bne.w	CTRL_0A_1			; jump if yes
;	endif
;		; - - - - - - - - - - - - - - - -
;		lsr.w	#1,d4				;
;		move.b	SCSP_DISDLPN(a5,d4.w),d5	; = xxxa aaaa B
;		andi.b	#$E0,d5				; = xxx0 0000
;		or.b	d3,d5				;
;		move.b	d5,SCSP_DISDLPN(a5,d4.w)	;
;		add.w	d4,d4				;
;CTRL_0A_1:	addi.w	#slot_wk_unit,d4		;
;		dbra	d7,CTRL_0A_lp
;		rts



			.public		CTRL_0A
CTRL_0A:
		andi.b	#$7F,d3				; d3.b = MIDI panning point 0(L) ～ 40H(C) ～ 7FH(R)
		lsr.b	#2,d3
		subi.b	#$10,d3
		bcc.s	?100
		not.b	d3
		addi.b	#$10,d3				; d3.b = SCSP panning point 1FH(L)～10H(C)00H～0FH(R)
	?100:

		move.w	knr_kanri_ofst(a6),d0		;
		bset.b	#7,knr_MIDI_PAN(a6,d0.w)	; set Layer PAN off
		move.b	knr_MIDI_PAN(a6,d0.w),d4	;
		btst	#6,d4				; SEQ PAN on ?
		beq.s	?sequence_pan_off

		btst.b	#7,SND_OUT_ST(a6)		; MONO/STEREO status
		bne.s	?mono

		bra	?end_of_control			; seq pan onでステレオのときseq panにしたがう

	?mono:	clr.w	d3
		bra.s	?start_control

	?sequence_pan_off:
		btst.b	#7,SND_OUT_ST(a6)		; MONO/STEREO status
		bne.s	?mono

		ori.b	#$80,d3				; set layer PAN off
		move.b	d3,knr_MIDI_PAN(a6,d0.w)	;
		andi.b	#$1F,d3				;


	; 発音中スロットの同一 MIDI chの全てに対して PAN を更新

		move.w	_tmp_kanri(a6),d0

	?start_control:
		moveq	#slot_size-1,d7			; loop size
		moveq	#0,d4				;
		lea	slot_work(a6),a0		;

	?slot_loop:
		cmp.b	sl_MIDI(a0,d4.w),d1		;
		bne	?function_false			; jump if not equal MIDI ch#

		cmp.w	_sl_kanri(a0,d4.w),d0		;
		bne	?function_false			; jump if not equal 管理番号

		btst.b	#PCM_flg,PSPN(a0,d4.w)		; 95/06/28 PCM stream playing ?
		bne.w	?function_false			; jump if yes

			.if ENGN
		btst.b	#ENGN_flg,sl_flag1(a0,d4.w)	; Engine ?
		bne.w	?function_false			; jump if yes
			.endif

		lsr.w	#1,d4				;
		move.b	SCSP_DISDLPN(a5,d4.w),d5	; = xxxa aaaa B
		andi.b	#$E0,d5				; = xxx0 0000
		or.b	d3,d5				;
		move.b	d5,SCSP_DISDLPN(a5,d4.w)	;
		add.w	d4,d4				;

	?function_false:
		addi.w	#slot_wk_unit,d4		;
		dbra	d7,?slot_loop

	?end_of_control:
		rts


;************************************************************************
;【機能】 ＭＩＤＩコントロールチェンジ[$Bn,$40,$xx]制御。ダンパー	*
;【入力】a5   : FH1005 top						*
;	 d1.w : MIDI ch# ( 0 ～ 1F )					*
;        d3.b : Parameter ( 00 ～ 7FH )				94/07/26*
;************************************************************************

; A.Miyazawa	{

;		global	CTRL_40
;CTRL_40:	; Hold1(dumper)
;
;		move.w	d1,d7
;		lsl.w	#5,d7			; = knr_unit * MIDI ch#
;		move.w	_tmp_kanri(a6),d6	; = 発音管理番号×200H
;		add.w	d6,d7			; + 発音管理番号×200H
;		move.b	knr_MIDI_flg(a6,d7.w),d0	; bit 6 = Damper on/off
;		andi.b	#%01000000,d3		; Damper on/off
;		bne.s	Damper_on		;
;
;		global	Damper_off
;Damper_off:	andi.b	#%10111111,d0		; set Damper off mode
;		move.b	d0,knr_MIDI_flg(a6,d7.w)	; = MIDI status 更新
;
;		moveq	#slot_size,d7		;
;		sub.w	off_slot_cnt(a6),d7	; = key-on中 slot数
;		beq.s	ret_11			;
;		subq.w	#1,d7			; loop size
;		lea	_KEYHISTB(a6),a0	;
;		lea	slot_work(a6),a4	;
;		move.w	HIS_off_pt(a6),d0	;
;DMP_off_lp:	andi.w	#HOPM,d0		; 0,2,4,...,3EH
;		move.w	(a0,d0.w),d4		;
;		andi.w	#KHMSK,d4		; $7C0
;		cmp.b	sl_MIDI(a4,d4.w),d1	; MIDI ch# equal ?
;		bne.s	DMP_off_1
;		cmp.w	_sl_kanri(a4,d4.w),d6	; 発音管理番号 equal ?
;		bne.s	DMP_off_1
;
;		btst.b	#flg_KON,sl_flag2(a4,d4.w)	; key-on(発音)中 ?
;		beq.s	DMP_off_1			; jump if key-off中
;		btst.b	#flg_non,sl_flag2(a4,d4.w)	; Note-on中?
;		bne.s	DMP_off_1			; jump if Note-on中
;		; Note-off 入力に対して Damperによる Key-off 未実行
;;@		move.b	PSPN(a4,d4.w),d2	; PCM_flg on ?
;;@		bmi.s	DMP_off_1		; jump if PCM Stream play 中
;		move.b	sl_note(a4,d4.w),d2	; ready MIDI Note#
;		move.b	sl_velo(a4,d4.w),d3	; ready MIDI velo#
;		movem.l	d0-d7/a0-a4,-(SP)	; reg. push
;		jsr	Note_off(pc)
;		movem.l	(SP)+,d0-d7/a0-a4	; reg. pop
;DMP_off_1:	addq.w	#2,d0
;		dbra	d7,DMP_off_lp
;ret_11:		rts
;
;;		global	Damper_on
;Damper_on:	ori.b	#%01000000,d0		; set Damper on mode
;		move.b	d0,knr_MIDI_flg(a6,d7.w)	; = MIDI status 更新
;		rts
;
;
			.public		CTRL_40
			.public		func_damper_off

CTRL_40:	; Hold1(dumper)

		move.w	d1,d7
		lsl.w	#5,d7				; management number * 0x20
		move.w	_tmp_kanri(a6),d6		; management number * 0x200
		add.w	d6,d7
		move.b	knr_MIDI_flg(a6,d7.w),d0	; bit 6 = Damper on/off
		andi.b	#%01000000,d3			; Damper on/off
		bne.s	func_damper_on

		andi.b	#%10111111,d0			; set Damper off mode
		move.b	d0,knr_MIDI_flg(a6,d7.w)	; = MIDI status 更新

func_damper_off:
		moveq	#slot_size,d7			;
		sub.w	off_slot_cnt(a6),d7		; = key-on中 slot数
		beq.s	?end_of_damper_off
		subq.w	#1,d7				; loop size
		lea	_KEYHISTB(a6),a0		;
		lea	slot_work(a6),a4		;
		move.w	HIS_off_pt(a6),d0		;

	?main_loop:
		andi.w	#HOPM,d0			; 0,2,4,...,3EH
		move.w	(a0,d0.w),d4			;
		andi.w	#KHMSK,d4			; $7C0
		cmp.b	sl_MIDI(a4,d4.w),d1		; MIDI ch# equal ?
		bne.s	?function_false

		cmp.w	_sl_kanri(a4,d4.w),d6		; 発音管理番号 equal ?
		bne.s	?function_false

		btst.b	#flg_KON,sl_flag2(a4,d4.w)	; key-on(発音)中 ?
		beq.s	?function_false			; jump if key-off中

		btst.b	#flg_non,sl_flag2(a4,d4.w)	; Note-on中?
		bne.s	?function_false			; jump if Note-on中

	; Note-off 入力に対して Damperによる Key-off 未実行

;@		move.b	PSPN(a4,d4.w),d2		; PCM_flg on ?
;@		bmi.s	?function_false			; jump if PCM Stream play 中
		move.b	sl_note(a4,d4.w),d2		; ready MIDI Note#
		move.b	sl_velo(a4,d4.w),d3		; ready MIDI velo#

		movem.l	d0-d7/a0-a4,-(sp)
		bsr	Note_off
		movem.l	(sp)+,d0-d7/a0-a4

	?function_false:
		addq.w	#2,d0
		dbra	d7,?main_loop

	?end_of_damper_off:
		rts

func_damper_on:
		ori.b	#%01000000,d0			; set Damper on mode
		move.b	d0,knr_MIDI_flg(a6,d7.w)	; = MIDI status 更新
		rts

;		}

;************************************************************************
;【 機 能 】 ＭＩＤＩコントロールチェンジ[$Bn,$5B,$xx]制御。		*
;	     ＤＳＰ Ｍicro Ｐrogram を更新する。			*
;【 入 力 】a5   : FH1005 top						*
;	    d1.w : MIDI ch# ( 0 ～ 1F )					*
;           d3.b : Parameter ( 00 ～ 7FH )				*
;【 出 力 】nothing							*
;【destroy】a0/a1/d0/d2.b/d7						*
;【 hold  】a5/a6							*
;************************************************************************
		global		CTRL_5B
CTRL_5B_er0:	bset.b	#ERRb_9,Mem_err_bit+2	; cannot find DSP-Prg-ID
		rts
CTRL_5B_er1:	bset.b	#ERRb10,Mem_err_bit+2	; not DSP-Prg down load
		rts
CTRL_5B_er2:	bset.b	#ERRb11,Mem_err_bit+2	; cannot find DSP-RAM-ID
		rts
CTRL_5B_er3:	bset.b	#ERRb12,Mem_err_bit+2	; DSP access area unit is 2000H
		rts
CTRL_5B_er4:	bset.b	#ERRb13,Mem_err_bit+2	; jump if Memory 不足
		rts
CTRL_5B_er5:	bset.b	#ERRb19,Mem_err_bit+1	; jump if R/W size > $20040
		rts
er_03:		bset.b	#ERRb22,Mem_err_bit+1	; Effect change No. > 0FH
		rts
CTRL_5B:
		cmpi.b	#$10,d3
		bcc.s	er_03			; jump if MIDI parameter > 0FH
		move.b	d3,d1
		ori.b	#DSP_PRG_ID*$10,d1
		moveq	#DSP_RAM_ID*$10,d3
		;-------------------------------;
		;    該当ＤＳＰ番号の検索	;
		;-------------------------------;
		lea	bs_AMAPC,a0		; area map current work top
		moveq	#256/8-1,d7		; loop size
CTRL_5B_lp:	move.b	(a0),d0			; 
		bmi	CTRL_5B_er0		; jump if not find DSP-Prg-ID
		cmp.b	d0,d1			;
		beq.s	CTRL_5B_4		;
		lea	8(a0),a0
		dbra	d7,CTRL_5B_lp
		bra	CTRL_5B_er0		; jump if not find DSP-Prg-ID
CTRL_5B_4:	bclr.b	#ERRb_9,Mem_err_bit+2	;
		move.l	(a0)+,d0		;
		andi.l	#$0FFFFF,d0		; = DSP Micro Prg top addr
		move.l	(a0),d2			;
		bpl	CTRL_5B_er1		; jump if not data ready
		bclr.b	#ERRb10,Mem_err_bit+2	;
		andi.l	#$0FFFFF,d2		; d2 = size
		movea.l	d0,a0			; a0 = DSP Micro Prg top addr
		move.l	d0,DSP_PRG_top(a6)	; save
		;-------------------------------;
		;  該当ＤＳＰ-ＲＡＭ番号の検索	;
		;-------------------------------;
		lea	bs_AMAPC,a1		; area map current work top
		moveq	#256/8-1,d7		; loop size
CTRL_5B_4lp:	move.b	(a1),d0			; 
		bmi	CTRL_5B_er2		; jump if not find DSP-RAM-ID
		bclr.b	#ERRb11,Mem_err_bit+2	;
		andi.b	#$70,d0
		cmp.b	d0,d3			; DSP RAM ID ?
		beq.s	CTRL_5B_7		; jump if Yes
		lea	8(a1),a1
		dbra	d7,CTRL_5B_4lp
		bra	CTRL_5B_er2		; jump if not find DSP-RAM-ID
CTRL_5B_7:	move.l	(a1)+,d5		;
		move.w	d5,d3
		andi.w	#$1FFF,d3
		bne	CTRL_5B_er3		; DSP access area unit is 2000H
		bclr.b	#ERRb12,Mem_err_bit+2	; DSP access area unit is 2000H
		andi.l	#$0FE000,d5		; d5 = DSP access area top
		move.l	(a1),d3			;
		andi.l	#$0FFFFF,d3		; d3 = size

	cmpi.l	#$20040+1,d3
	bcc.w	CTRL_5B_er5
	bclr.b	#ERRb19,Mem_err_bit+1	; jump if R/W size > $20040
;@		andi.l	#$01FFFF,d3		; d3 = size
		;-------------------------------;
		;  DSP access Memory size check	
		; raedy a0 = DSP Micro Prg top addr
		; 	d2 = size		
		; 	d5 = DSP access area top	
		; 	d3 = size		
		;-------------------------------;
		move.l	d5,DSP_RW_top(a6)	;
		move.l	d3,DSP_RW_sz(a6)	;

		move.b	DL_NEL(a0),DFL_ELMNT_NO(a6)
		move.l	#$4000,d1		; RBLen unit
		move.b	DL_RBL(a0),d0		; = RBLEN 0=$04000
						;	  1=$08000
						;	  2=$10000
		andi.w	#3,d0			;	  3=$20000
		beq.s	CTRL_5B_2		; jump if RBLen = 0
		lsl.l	d0,d1			; d1 = 2exp[RBLen] * $4000
CTRL_5B_2:	addi.l	#$40,d1			; + 20H*2(瞬時値書込area)
		moveq	#0,d4			
		move.b	DL_NCT(a0),d4		; = COEF table数
		beq.s	CTRL_5B_3		; jump if COEF table nothing
		mulu	#$A00,d4
CTRL_5B_3:	add.l	d4,d1			; + COEF table size
		cmp.l	d1,d3
		bcs	CTRL_5B_er4		; jump if Memory 不足
		bclr.b	#ERRb13,Mem_err_bit+2	; jump if Memory 不足

		move.b	#8,EFCT_CHG_CNT(a6)	; set Effect change exe mode
		rts
;************************************************************************
;     Ｐitch Ｂend							*
;【入力】 a6   = CPU work top addr.					*
;	  d1.w = MIDI 1st. byte	0 ～ 1FH ( $En )			*
;	  d2.b = MIDI 2nd. byte	0 ～ 7FH ( LSB )			*
;	  d3.b = MIDI 3rd. byte	0 ～ 7FH ( MSB )		94/07/26*
;************************************************************************
		global		MIDI_En
MIDI_En:	andi.w	#$7F,d2			; LSB
		andi.w	#$7F,d3			; MSB
		lsl.w	#7,d3
		or.w	d3,d2			; d2 = 00xx xxxx xxxx xxxx
	
		subi.w	#$2000,d2		; d2 = -$2000～0～$1FFF

		move.w	d1,d4			;
		lsl.w	#5,d4			; = knr_unit * MIDI ch#
		add.w	_tmp_kanri(a6),d4	; + 発音管理番号×200H
		move.b	knr_PROG_no(a6,d4.w),d0	;
		movea.l	knr_BANK_adr(a6,d4.w),a2	; = desti. SCSPBIN top address
		add.w	d0,d0			;
		move.w	BIN_VOICE(a2,d0.w),d0	; voice#xx offset addr
		move.b	V_PM_BR(a2,d0.w),d0	; low 4bit = Pitch Bend range
		andi.w	#$0f,d0			; = 0 ～ D
		add.w	d0,d0			; = 0,2,4,6,8,...1AH
		add.w	d0,d0			; = 0,4,8,10H,...34H
		jmp	En_JPTB(pc,d0.w)	;
En_JPTB:	clr.w	d2			; ± 0
		bra.s	EN_0x
		asr.w	#5,d2			; ± 100セント
		bra.s	EN_0x
		asr.w	#4,d2			; ± 200セント
		bra.s	EN_0x
		asr.w	#4,d2			; ± 300セント
		bra.s	EN_00
		asr.w	#3,d2			; ± 400セント
		bra.s	EN_0x
		asr.w	#3,d2			; ± 500セント
		bra.s	EN_01
		asr.w	#3,d2			; ± 600セント
		bra.s	EN_00
		asr.w	#3,d2			; ± 700セント 400+200+100
		bra.s	EN_04
		asr.w	#2,d2			; ± 800セント
		bra.s	EN_0x
		asr.w	#2,d2			; ± 900セント 800+100
		bra.s	EN_05
		asr.w	#2,d2			; ± 1000セント 800+200
		bra.s	EN_01
		asr.w	#2,d2			; ± 1100セント 800+200+100
		bra.s	EN_06
		asr.w	#2,d2			; ± 1200セント 800+400
		bra.s	EN_00
		asr.w	#1,d2			; ± 2400セント 1000+800
;@		bra.s	EN_00
EN_00:		move.w	d2,d3
		moveq	#1,d4
		bra.s	EN_07
EN_06:		move.w	d2,d3
		asr.w	#2,d3
		bra.s	EN_02
EN_05:		move.w	d2,d3
		moveq	#3,d4
		bra.s	EN_07
EN_01:		move.w	d2,d3
		moveq	#2,d4
		bra.s	EN_07
EN_04:		move.w	d2,d3
		asr.w	#1,d3
EN_02:		add.w	d3,d2
		moveq	#1,d4
EN_07:		asr.w	d4,d3
		add.w	d3,d2
EN_0x:
;
;		d2.w ＝ -$0C00 ～ +$0BFF ( Pitch Bend data )
;
		move.w	_tmp_kanri(a6),d3	; = 発音管理番号×200H
		lsl.w	#5,d1			; = MIDI ch# * knr_unit
		add.w	d1,d3			;
		move.w	d2,knr_PBend_BF(a6,d3.w)	; save
ret_80:		rts

;===============================================================;
;	MIDI CONTROL CHANGE [$Bn,$50,$xx]	95/02/03	;
;		Q sound position set				;
;	input	d1.w : EFREG# ( 本来は MIDI ch# : $00～$1F )	;
;		d3.b : Parameter				;
;				edit by Y.Kashima		;
;===============================================================;
		global		CTRL_50
		extern	xseq_qsound
CTRL_50:
		move.b	d1,d0		; channel
		move.b	d3,d1		; position
		bsr	xseq_qsound	;
		rts			;
;===============================================================;
;	MIDI CONTROL CHANGE [$Bn,$5(1-3),$xx]	95/04/11	;
;		3D sound set					;
;	input	d3.b : Parameter				;
;				edit by Y.Kashima		;
;===============================================================;
		global		CTRL_51,CTRL_52,CTRL_53
		extern	xseq_YMH3Dw
CTRL_51:
		lea.l	Y3D_buf,a0	;
		move.b	d3,d0		; d0=distance
		move.b	d0,(a0)		;
		move.b	1(a0),d1	; d1=azimuth
		move.b	2(a0),d2	; d2=elevation
		bsr	xseq_YMH3Dw	;
		rts			;
CTRL_52:
		lea.l	Y3D_buf,a0	;
		move.b	d3,d1		; d1=azimuth
		move.b	d1,1(a0)	;
		move.b	(a0),d0		; d0=distance
		move.b	2(a0),d2	; d2=elevation
		bsr	xseq_YMH3Dw	;
		rts			;
CTRL_53:
		lea.l	Y3D_buf,a0	;
		move.b	d3,d2		;
		move.b	d2,2(a0)	; d2=elevation
		move.b	(a0),d0		; d0=distance
		move.b	1(a0),d1	; d1=azimuth
		bsr	xseq_YMH3Dw	;
		rts			;
Y3D_buf:
		db	0
		db	0
		db	0

	end


