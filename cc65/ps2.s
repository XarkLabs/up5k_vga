; ---------------------------------------------------------------------------
; ps2.s - ps2 interface routines
; 2019/04/01 E. Brombaugh
; Note - requires 65C02 support
; ---------------------------------------------------------------------------
;

.include "sbc_defines.inc"

.export		_ps2_init
.export		_ps2_rx_nb

.segment	"KEY_DAT"

; storage for key processing @ $0213-$0216
cl_state:	.byte		$00
key_temp:	.byte		$00

.segment	"CODE"
; ---------------------------------------------------------------------------
; PS2 initializer

.proc _ps2_init: near
			lda #$01				; reset PS2
			sta PS2_CTRL
			stz PS2_CTRL			; normal operation
			stz cl_state			; init caps lock state
			jsr _ps2_caps_led_set	; update caps led
			rts
.endproc

; ---------------------------------------------------------------------------
; non-blocking raw RX - returns 1 in X if code in A and 0 in X if none

.proc _ps2_rx_nb: near
			ldx #0
			lda	PS2_CTRL			; check for RX ready
			and	#$01
			beq	nb_no_chr
			ldx #1
			lda	PS2_DATA			; receive ascii
nb_no_chr:	sta key_temp
			lda	PS2_CTRL			; check if capslock changed
			eor cl_state
			and #$10
			beq no_chg				; if no change then return
			jsr _ps2_caps_led_set	; else update caps led
no_chg:		lda key_temp
			rts
.endproc

; ---------------------------------------------------------------------------
; handle caps lock LED status - enter w/ no RX 

.proc _ps2_caps_led_set: near
			phx
			phy
			lda PS2_RDAT			; clear raw ready
			lda PS2_CTRL
			sta cl_state			; update shadow copy
			ldy	#$00				; init timeout counter
			ldx #$00				; code to send for caps lock off
			and #$10
			beq tx_w1
			ldx #$04				; code to send for caps lock on
tx_w1:		lda PS2_CTRL			; wait for TX ready
			and #$20				; tx_rdy
			bne	tx_d1
			dey						; dec timeout
			beq	done				; if zero, timed-out
			jsr	slow				; delay
			bra tx_w1
tx_d1:		lda #$ED				; LED command
			sta PS2_DATA			; send
			ldy	#$00				; init timeout counter
tx_w2:		lda PS2_CTRL			; wait for TX ready
			and #$20				; tx_rdy
			bne tx_d2
			dey						; dec timeout
			beq	done				; if zero, timed-out
			jsr	slow				; delay
			bra	tx_w2
tx_d2:		ldy	#$00				; init timeout counter
rx_w1:		lda PS2_RSTA			; wait for raw ready
			and #$01				; rx_rdy
			bne rx_d1
			dey						; dec timeout
			beq	done				; if zero, timed-out
			jsr	slow				; delay
			bra	rx_w1
rx_d1:		lda PS2_RDAT			; get ACK - don't bother checking
			stx	PS2_DATA			; send capslock status
			ldy	#$00				; init timeout counter
tx_w3:		lda PS2_CTRL			; wait for TX ready
			and #$20				; tx_rdy
			bne done
			dey						; dec timeout
			beq	done				; if zero, timed-out
			jsr	slow				; delay
			bra	tx_w3
done:		ply
			plx
			rts

slow:		clc
			lda	#$00
slow_lp:	adc	#$01
			bne	slow_lp
			rts

.endproc
