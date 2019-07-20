; ---------------------------------------------------------------------------
; video.s - video interface routines
; 2019-03-20 E. Brombaugh
; Note - requires 65C02 support
; ---------------------------------------------------------------------------
;

.export		_video_init
.export		_video_chrout

CURSR_CHR	=	'_'						; character to use for cursor

; ---------------------------------------------------------------------------
; video initializer

.proc _video_init: near
			lda #$F3		; white/blue default color
			sta	$0206
			lda vidtab		; initial cursor location
			sta $0200
			ldx #vi_clr_end-vi_clr	; copy modifiable code to pg 2 RAM
vi_clrlp0:	lda vi_clr,X
			sta $0207,X
			dex
			bpl vi_clrlp0
			ldx #$20		; clear $2000
			ldy #$00		; init offset
vi_clrlp1:	lda #$01
			sta	$F600
			lda	$0206
			jsr $0207		; set color for page
			stz	$F600
			lda	#' '
			jsr $0207		; set char for page
			inc $0209		; inc dest high addr
			dex
			bne vi_clrlp1	; no, keep looping
			rts

vi_clr:		sta $D000,Y		; $207 $208=L $209=H
			iny				; $20a
			bne	vi_clr		; $20b $20c
vi_clr_end:	rts				; $20d
.endproc

; ---------------------------------------------------------------------------
; video character output for VGA 100x75 display

.proc _video_chrout: near
			sta $0202		; save output char
			pha				; save regs
			phx
			phy
			cmp #$00
			beq vco_end		; skip to end if null chr
			cmp #$08
			beq vco_bksp	; handle backspace
			cmp #$0C		; ^L clear screen
			beq	vco_clr
			cmp #$0A
			beq vco_lf		; handle linefeed
			cmp #$0D		; is it a carriage return?
			bne vco_norm	; no - send normal char to video
			jsr vco_cr1		; handle carriage return normally
			bra vco_end		; skip to end
vco_clr:	jsr	_video_init+5
			bra vco_end
vco_norm:	sta $0201		; save char in-process
			jsr vco_vout	; output to video memory
			inc $0200
			lda $FFE1		; get default width
			clc
			adc $FFE0		; add to default starting loc
			cmp $0200		; compare to current position
			bmi vco_autocr	; if over then do auto carriage return
vco_nxt:	jsr vco_cr3		; carriage return entry 3

vco_end:	ply				; restore regs
			plx
			pla
			rts
; .......................................................................
; video text output handle backspace
vco_bksp:	ldy $0200		; get current cursor pos
			cpy $FFE0		; compare to initial pos
			beq vco_end		; exit w/o change if equal
			lda #$20		; erase current cursor
			jsr vco_vout1
			dey
			sty $0200		; decrement cursor loc
			lda #CURSR_CHR	; draw new cursor
			jsr vco_vout1
			bra vco_end		; exit

; .......................................................................
; video text output handle auto carriage return when line length exceeded
vco_autocr: jsr vco_cr2		; handle auto cr w/o char

; .......................................................................
; video text output handle linefeed
vco_lf:		jsr vco_vout	; output char to video mem
			ldy #vco_zp_end-vco_zp-1	; copy modifiable code to pg 2 RAM
vco_lflp0:	lda vco_zp,Y
			sta $0207,Y
			dey
			bpl vco_lflp0
			ldx #$EC		; get high addr for 7.5k
			ldy #$00		; init ptr
vco_lflp1:	stz	$F600		; glyph access
			jsr $0207		; scroll glyphs
			lda #$01
			sta	$F600		; color access
			jsr $0207		; scroll color
			inc $0209		; inc src high addr
			inc $020C		; inc dst high addr
			cpx $0209
			bne vco_lflp1	; no, keep looping
			ldx	#$01
vco_lflp2:	ldy #$00
vco_lflp3:	lda $EC64,Y
			sta	$EC00,Y
			iny
			cpy	#$E8
			bne	vco_lflp3
			stz	$F600		; glyph access
			dex
			bpl	vco_lflp2
			ldx	#$01
			stx	$F600		; color access
			lda	$206
vco_lflp4:	ldy #100-1		; line length
vco_lflp5:	sta	$ECE8,Y
			dey
			bpl vco_lflp5	; keep looping
			stz	$F600		; glyph access
			lda #' '		; load last line with spaces
			dex
			bpl	vco_lflp4
			bra	vco_nxt

; ---------------------------------------------------------------------------
; video text output char to vidmem routine
vco_vout:	ldy $0200		; get cursor loc
			lda $0201		; get char
vco_vout1:	stz	$F600
			sta $ECE8,Y		; 1k output
			lda #$01
			sta	$F600
			lda $0206
			sta $ECE8,Y		; 1k output
			stz	$F600
			rts


; ---------------------------------------------------------------------------
; video text output carriage return routine

vco_cr1:	jsr vco_vout	; output to video memory
vco_cr2:	lda $FFE0		; get default cursor location
			sta $0200		; store it in live location
vco_cr3:	ldy $0200		; get cursor loc
			lda $ECE8,Y		; get contents of video mem @ cursor loc for 1k
			sta $0201		; save it
			lda #CURSR_CHR	; cusror char
			bra vco_vout1	; output to video memory


; ---------------------------------------------------------------------------
; video text output zp scrolling code (copied to $0207-$0210)

vco_zp:		lda $D064,Y		; $207 $208=L $209=H
			sta $D000,Y		; $20a $20b=L $20c=H
			iny				; $20d
			bne	vco_zp		; $20e $20f
			rts				; $210
vco_zp_end:

.endproc

; ---------------------------------------------------------------------------
; table of data for video driver

.segment  "VIDTAB"

vidtab:
.byte		$0E					; $FFE0 - default starting cursor location
.byte		$48					; $FFE1 - default width
.byte		$00					; $FFE2 - vram size: 0 for 1k, !0 for 2k
