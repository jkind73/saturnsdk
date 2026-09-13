;=======================================================================;
;	DEC2.ASM  ( M6 data decoder )					;
;	Ver. 2.20 / 1994.10.26						;
;						by  新田勝貴		;
;=======================================================================;

	globals on

;	area_1 内での各変数の Offset

ofst_nxt_adr			equ	0
ofst_lp_start			equ	4
ofst_ret_of_ref			equ	8
ofst_top_of_track		equ	12
ofst_nxt_adr_in_tmp		equ	16
ofst_1st_tmp_in_lp		equ	20
ofst_rest_of_referenced		equ	24
ofst_dummy_1			equ	25
ofst_dummy_2			equ	26
ofst_dummy_3			equ	27
ofst_dummy_4			equ	28
ofst_dummy_5			equ	29
ofst_dummy_6			equ	30
ofst_dummy_7			equ	31

mc_add_to_delta_time:	macro
			moveq.l	#0,d7
			move.b	(a0)+,d7
			add.l	d7,d1
			endm

sq_decoder:	lsl.w	#5,d1			;*32
		lea.l	area_1(pc,d1),a1	; culc work adr of song in 
		add.w	d0,d0			;			area_1
		bne	jump_cont		;jump - 10 clk , through = 8 clk
tp_0:		move.l	(a1),a0
output_event:	moveq.l	#0,d0			;processing_status
		moveq.l	#0,d1			;delta time
		moveq.l	#0,d2			;channel number
		moveq.l	#0,d3			;MIDI CMD
		moveq.l	#0,d4			;MIDI Data 1
		moveq.l	#0,d5			;MIDI Data 2
		moveq.l	#0,d6			;gate time
get_1_event:	move.b	(a0)+,d2		;イベント取り出し
		cmpi.b	#7fh,d2			;イベント <= 7fh ?
		bhi	not_note

note:		;イベント <= 7f の時のルーチン
		move.b	(a0)+,d4		;note
		move.b	(a0)+,d5		;velo
		move.l	d2,d7
		add.w	d7,d7			;delta 最上位 bit だけ取り出す
		add.w	d7,d7
		move.w	d7,d3			;prepare gate
						;d3 は ext cmd で .w で使われて
						;いるので、必ず .w , .l で使い
						;直さないとゴミが入る
		andi.w	#FFh,d7
		add.w	d7,d7

		move.b	(a0)+,d3
		add.l	d3,d6			;d6 = gate

		move.b	(a0)+,d7		;d1 = delta
		add.l	d7,d1

		andi.b	#00011111b,d2		;make channel no.
		move.w	#90h,d3			;MIDI CMD

reference_check:
		cmp	ofst_rest_of_referenced(a1),d0
						;d0 = proseccing status , = 0
		bne.w	reference_check_cont	;jump when in referencing
		move.l	a0,(a1)
		move.l	d0,d7
		move.b	d2,d0			;d0 決定
		lsl.w	#8,d0			;1 byte to left
		add.l	d7,d0
		move.l	d6,d2			;d2 決定
		swap	d4
		add.b	d5,d4
		rts
area_1:
		ds.b	32*8

reference_check_cont:
		subq.b	#1,ofst_rest_of_referenced(a1)
		bne.b	store_nxt_read_point
		move.l	ofst_ret_of_ref(a1),(a1)
		move.l	d0,d7
		move.b	d2,d0			;d0 決定
		lsl.w	#8,d0			;1 byte to left
		add.l	d7,d0
		move.l	d6,d2			;d2 決定
		swap	d4
		add.b	d5,d4
		rts
store_nxt_read_point:
		move.l	a0,(a1)
end_of_decode:
		move.l	d0,d7
		move.b	d2,d0			;d0 決定
		lsl.w	#8,d0			;1 byte to left
		add.l	d7,d0
		move.l	d6,d2			;d2 決定
		swap	d4
		add.b	d5,d4
		rts
not_note:
		move.l	d2,d7
		subi.w	#80h,d7
		add.w	d7,d7
		move.w	event_jump_table(pc,d7),d3
		jmp	event_jump_table(pc,d3)

event_jump_table:
	dc.w	other_event-event_jump_table		;#80h(その他)
	dc.w	reference-event_jump_table		;#81h
	dc.w	loop-event_jump_table			;#82h
	dc.w	end_of_track-event_jump_table		;#83h
	dc.w	other_event-event_jump_table		;#84h(その他)
	dc.w	other_event-event_jump_table		;#85h(その他)
	dc.w	other_event-event_jump_table		;#86h(その他)
	dc.w	other_event-event_jump_table		;#87h(その他)
	dc.w	ext_gate_200h-event_jump_table		;#88h
	dc.w	ext_gate_800h-event_jump_table		;#89h
	dc.w	ext_gate_1000h-event_jump_table		;#8ah
	dc.w	ext_gate_2000h-event_jump_table		;#8bh
	dc.w	ext_delta_100h-event_jump_table		;#8ch
	dc.w	ext_delta_200h-event_jump_table		;#8dh
	dc.w	ext_delta_800h-event_jump_table		;#8eh
	dc.w	ext_delta_1000h-event_jump_table	;#8fh
	dc.w	other_event-event_jump_table		;#90h(その他)
	dc.w	other_event-event_jump_table		;#91h(その他)
	dc.w	other_event-event_jump_table		;#92h(その他)
	dc.w	other_event-event_jump_table		;#93h(その他)
	dc.w	other_event-event_jump_table		;#94h(その他)
	dc.w	other_event-event_jump_table		;#95h(その他)
	dc.w	other_event-event_jump_table		;#96h(その他)
	dc.w	other_event-event_jump_table		;#97h(その他)
	dc.w	other_event-event_jump_table		;#98h(その他)
	dc.w	other_event-event_jump_table		;#99h(その他)
	dc.w	other_event-event_jump_table		;#9ah(その他)
	dc.w	other_event-event_jump_table		;#9bh(その他)
	dc.w	other_event-event_jump_table		;#9ch(その他)
	dc.w	other_event-event_jump_table		;#9dh(その他)
	dc.w	other_event-event_jump_table		;#9eh(その他)
	dc.w	other_event-event_jump_table		;#9fh(その他)
	dc.w	poly_key_pressure-event_jump_table	;#a0h
	dc.w	poly_key_pressure-event_jump_table	;#a1h(その他)
	dc.w	poly_key_pressure-event_jump_table	;#a2h(その他)
	dc.w	poly_key_pressure-event_jump_table	;#a3h(その他)
	dc.w	poly_key_pressure-event_jump_table	;#a4h(その他)
	dc.w	poly_key_pressure-event_jump_table	;#a5h(その他)
	dc.w	poly_key_pressure-event_jump_table	;#a6h(その他)
	dc.w	poly_key_pressure-event_jump_table	;#a7h(その他)
	dc.w	poly_key_pressure-event_jump_table	;#a8h(その他)
	dc.w	poly_key_pressure-event_jump_table	;#a9h(その他)
	dc.w	poly_key_pressure-event_jump_table	;#aah(その他)
	dc.w	poly_key_pressure-event_jump_table	;#abh(その他)
	dc.w	poly_key_pressure-event_jump_table	;#ach(その他)
	dc.w	poly_key_pressure-event_jump_table	;#adh(その他)
	dc.w	poly_key_pressure-event_jump_table	;#aeh(その他)
	dc.w	poly_key_pressure-event_jump_table	;#afh(その他)
	dc.w	control_change-event_jump_table		;#b0h(その他)
	dc.w	control_change-event_jump_table		;#b1h(その他)
	dc.w	control_change-event_jump_table		;#b2h(その他)
	dc.w	control_change-event_jump_table		;#b3h(その他)
	dc.w	control_change-event_jump_table		;#b4h(その他)
	dc.w	control_change-event_jump_table		;#b5h(その他)
	dc.w	control_change-event_jump_table		;#b6h(その他)
	dc.w	control_change-event_jump_table		;#b7h(その他)
	dc.w	control_change-event_jump_table		;#b8h(その他)
	dc.w	control_change-event_jump_table		;#b9h(その他)
	dc.w	control_change-event_jump_table		;#bah(その他)
	dc.w	control_change-event_jump_table		;#bbh(その他)
	dc.w	control_change-event_jump_table		;#bch(その他)
	dc.w	control_change-event_jump_table		;#bdh(その他)
	dc.w	control_change-event_jump_table		;#beh(その他)
	dc.w	control_change-event_jump_table		;#bfh(その他)
	dc.w	program_change-event_jump_table		;#c0h(その他)
	dc.w	program_change-event_jump_table		;#c1h(その他)
	dc.w	program_change-event_jump_table		;#c2h(その他)
	dc.w	program_change-event_jump_table		;#c3h(その他)
	dc.w	program_change-event_jump_table		;#c4h(その他)
	dc.w	program_change-event_jump_table		;#c5h(その他)
	dc.w	program_change-event_jump_table		;#c6h(その他)
	dc.w	program_change-event_jump_table		;#c7h(その他)
	dc.w	program_change-event_jump_table		;#c8h(その他)
	dc.w	program_change-event_jump_table		;#c9h(その他)
	dc.w	program_change-event_jump_table		;#cah(その他)
	dc.w	program_change-event_jump_table		;#cbh(その他)
	dc.w	program_change-event_jump_table		;#cch(その他)
	dc.w	program_change-event_jump_table		;#cdh(その他)
	dc.w	program_change-event_jump_table		;#ceh(その他)
	dc.w	program_change-event_jump_table		;#cfh(その他)
	dc.w	channnel_pressure-event_jump_table	;#d0h(その他)
	dc.w	channnel_pressure-event_jump_table	;#d1h(その他)
	dc.w	channnel_pressure-event_jump_table	;#d2h(その他)
	dc.w	channnel_pressure-event_jump_table	;#d3h(その他)
	dc.w	channnel_pressure-event_jump_table	;#d4h(その他)
	dc.w	channnel_pressure-event_jump_table	;#d5h(その他)
	dc.w	channnel_pressure-event_jump_table	;#d6h(その他)
	dc.w	channnel_pressure-event_jump_table	;#d7h(その他)
	dc.w	channnel_pressure-event_jump_table	;#d8h(その他)
	dc.w	channnel_pressure-event_jump_table	;#d9h(その他)
	dc.w	channnel_pressure-event_jump_table	;#dah(その他)
	dc.w	channnel_pressure-event_jump_table	;#dbh(その他)
	dc.w	channnel_pressure-event_jump_table	;#dch(その他)
	dc.w	channnel_pressure-event_jump_table	;#ddh(その他)
	dc.w	channnel_pressure-event_jump_table	;#deh(その他)
	dc.w	channnel_pressure-event_jump_table	;#dfh(その他)
	dc.w	pitch_bend-event_jump_table		;#e0h(その他)
	dc.w	pitch_bend-event_jump_table		;#e1h(その他)
	dc.w	pitch_bend-event_jump_table		;#e2h(その他)
	dc.w	pitch_bend-event_jump_table		;#e3h(その他)
	dc.w	pitch_bend-event_jump_table		;#e4h(その他)
	dc.w	pitch_bend-event_jump_table		;#e5h(その他)
	dc.w	pitch_bend-event_jump_table		;#e6h(その他)
	dc.w	pitch_bend-event_jump_table		;#e7h(その他)
	dc.w	pitch_bend-event_jump_table		;#e8h(その他)
	dc.w	pitch_bend-event_jump_table		;#e9h(その他)
	dc.w	pitch_bend-event_jump_table		;#eah(その他)
	dc.w	pitch_bend-event_jump_table		;#ebh(その他)
	dc.w	pitch_bend-event_jump_table		;#ech(その他)
	dc.w	pitch_bend-event_jump_table		;#edh(その他)
	dc.w	pitch_bend-event_jump_table		;#eeh(その他)
	dc.w	pitch_bend-event_jump_table		;#efh(その他)
	dc.w	other_event-event_jump_table		;#f0h(その他)
	dc.w	other_event-event_jump_table		;#f1h(その他)
	dc.w	other_event-event_jump_table		;#f2h(その他)
	dc.w	other_event-event_jump_table		;#f3h(その他)
	dc.w	other_event-event_jump_table		;#f4h(その他)
	dc.w	other_event-event_jump_table		;#f5h(その他)
	dc.w	other_event-event_jump_table		;#f6h(その他)
	dc.w	other_event-event_jump_table		;#f7h(その他)
	dc.w	other_event-event_jump_table		;#f8h(その他)
	dc.w	other_event-event_jump_table		;#f9h(その他)
	dc.w	other_event-event_jump_table		;#fah(その他)
	dc.w	other_event-event_jump_table		;#fbh(その他)
	dc.w	other_event-event_jump_table		;#fch(その他)
	dc.w	other_event-event_jump_table		;#fdh(その他)
	dc.w	other_event-event_jump_table		;#feh(その他)
	dc.w	other_event-event_jump_table		;#ffh(その他)
reference:									;reference コマンドの処理
		moveq.l	#0,d7
		move.b	(a0)+,d7		;奇数番地からの読み込みを考えて
						;バイトアクセスを 2 回している
						;( ワードアクセスはしない )
		lsl.w	#8,d7
		move.b	(a0)+,d7		;d7=トラック先頭から参照先までの
						;オフセット
		move.b	(a0)+,ofst_rest_of_referenced(a1)
						;参照イベント数記録
		move.l	a0,ofst_ret_of_ref(a1)
						;戻り先 ( reference の次 )
						;次回読み出しアドレス ( = 参照先 )

		move.l	ofst_top_of_track(a1),a6
		lea.l	(a6,d7.l),a0		;a0 = 次回 曲内アクセス位置
						;次回読み出し位置はこのルーチン
						;(= ファイル)の最後の方で書く
						;ので、area_1 にはここでは
						;書かなくて良い
		bra	get_1_event
loop:
		mc_add_to_delta_time		;△time 加算
		cmpi.l	#0,ofst_lp_start(a1)	;今までにループコマンドがあったか ?
		beq	loop_cmd_is_not_existed	;なかったら飛ぶ
											;あった時のルーチン
		move.l	ofst_lp_start(a1),a0
		bra	get_1_event

loop_cmd_is_not_existed:			;今までにループコマンドがなかった
						;時のルーチン
		move.l	a0,ofst_lp_start(a1)
		bra	get_1_event

end_of_track:					;トラック終端の処理
		moveq.l	#1,d0
		bra	end_of_decode
program_change:					;#c0h
channnel_pressure:				;#d0h
		move.b	(a0)+,d4
		bclr.l	#7,d4							;Data 1
		bra	continuous_ctrl_cont
pitch_bend:									;#e0h
		moveq.l	#0,d4
		move.b	(a0)+,d5
		bclr.l	#7,d5			;Data 2
		bra	continuous_ctrl_cont
poly_key_pressure:				;#a0h
control_change:					;#b0h
		move.b	(a0)+,d4		;Data 1
		move.b	(a0)+,d5		;Data 2
		bclr.l	#7,d4

continuous_ctrl_cont:
		bne	continuous_ctrl_ne	;channel <= 15 ( count from 0 )
		move.l	d2,d3			;d3 は ext cmd で .w で使われて
						;いるので、必ず .w , .l で使い
						;直さないとゴミが入る
		andi.b	#00001111b,d2
		andi.b	#11110000b,d3		;clear lower 4 bit of midi cmd

		mc_add_to_delta_time		;△time 加算
		bra	reference_check

continuous_ctrl_ne
		move.l	d2,d3			;d3 は ext cmd で .w で使われて
						;いるので、必ず .l で使い直さないと
						;ゴミが入る
		andi.b	#00001111b,d2
		bset	#4,d2
		andi.b	#11110000b,d3		;clear lower 4 bit of midi cmd

		mc_add_to_delta_time		;△time 加算
		bra	reference_check




ext_gate_200h:					;#88h
ext_gate_800h:					;#89h
ext_gate_1000h:					;#8ah
ext_gate_2000h:					;#8bh
		move.w	ext_table(pc,d7),d3
		add.l	d3,d6
		bra	get_1_event
ext_delta_100h:					;#8ch
ext_delta_200h:					;#8dh
ext_delta_800h:					;#8eh
ext_delta_1000h:				;#8fh
		move.w	ext_table(pc,d7),d3
		add.l	d3,d1
		bra	get_1_event
ext_table:
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0200h		;gate
	dc.w	0800h
	dc.w	1000h
	dc.w	2000h
	dc.w	0100h		;delta
	dc.w	0200h
	dc.w	0800h
	dc.w	1000h
other_event:					;イベント取り出しミス時の処理
		move.l	#255,d0			;異常終了ステータス
		bra	end_of_decode

jump_cont:
		move.w	top_of_jump_table(pc,d0),d0
		jmp	top_of_jump_table(pc,d0)
top_of_jump_table:
		dc.w	tp_0-top_of_jump_table
		dc.w	tp_1-top_of_jump_table
		dc.w	tp_2-top_of_jump_table
		dc.w	tp_3-top_of_jump_table

tp_1:		adda.w	4(a0),a0		;演奏データ ADR -> area_1
		move.l	a0,(a1)
		move.l	a0,ofst_top_of_track(a1)

		moveq.l	#0,d7
		move.l	d7,ofst_lp_start(a1)	;area_1 内ループ開始位置クリア
		move.b	d7,ofst_rest_of_referenced(a1)
		bra	output_event

tp_2:		moveq.l	#0,d0			;status
		movea.l	a0,a2
		adda.w	4(a0),a2		;演奏データ ADR -> area_1
		movea.l	a2,ofst_top_of_track(a1)

		moveq.l	#0,d7
		move.l	d7,ofst_1st_tmp_in_lp(a1)
		move.w	6(a0),d7
		beq	prepare_to_out_1st_tmp
										;when tempo loop exists
		add.l	a0,d7
		move.l	d7,ofst_1st_tmp_in_lp(a1)

prepare_to_out_1st_tmp:
		lea	8(a0),a2
		bra	output_1_tmp_event

tp_3:		moveq.l	#0,d0
		move.l	ofst_nxt_adr_in_tmp(a1),a2	;今回読み出し位置決定
		cmpa.l	ofst_top_of_track(a1),a2
		bne	output_1_tmp_event
		; when rest of tempo not exists
		cmpi.l	#0,ofst_1st_tmp_in_lp(a1)	;tempo loop is exists?
		bne	tempo_lp
										;when tempo loop not exists or old ver.
		moveq.l	#1,d0
		bra	end_of_decode
tempo_lp:
		move.l	ofst_1st_tmp_in_lp(a1),ofst_nxt_adr_in_tmp(a1)
		move.l	ofst_nxt_adr_in_tmp(a1),a2

;△ time 追い出し、テンポイベント出力
;入力 :
;		a1,今回読み出し位置
;		a1,area_1 内 その曲の頭
;破壊 :
;出力 :

output_1_tmp_event:
		move.l	(a2)+,d1		;step
		move.l	(a2)+,d6		;tempo value

		move.l	a2,ofst_nxt_adr_in_tmp(a1)	;次回に備えて読み位置保存
		bra	end_of_decode
sounddata:									;この下に曲データがリンクされる。
