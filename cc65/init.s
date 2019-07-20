; ---------------------------------------------------------------------------
; init.s - 6502 initializer for up5k_basic project
; 2019-03-20 E. Brombaugh
; Note - requires 65C02 support
; ---------------------------------------------------------------------------
;

.include "sbc_defines.inc"

.import		_acia_init
.import		_video_init
.import		_spi_init
.import		_ledpwm_init
.import		_ps2_init
.import		_basic_init
.import		_cmon
.import		_cmonbrk
.import		_input
.import		_output
.import		_strout
.import		BAS_COLDSTART
.import		BAS_WARMSTART

; ---------------------------------------------------------------------------
; Reset vector

_init:      sei                     ; Disable IRQ
            ldx #$FF                ; Initialize stack pointer to stack top 
            txs
            cld                     ; Clear decimal mode

; ---------------------------------------------------------------------------
; Init ACIA
			jsr _acia_init
			
; ---------------------------------------------------------------------------
; Init video
			jsr _video_init

; ---------------------------------------------------------------------------
; Startup Message
			lda #.lobyte(startup_msg)
			ldy #.hibyte(startup_msg)
			jsr _strout
			
; ---------------------------------------------------------------------------
; Init spi
			jsr _spi_init

; ---------------------------------------------------------------------------
; Init led pwm
			jsr _ledpwm_init

; ---------------------------------------------------------------------------
; Init ps2 input
			jsr _ps2_init

; ---------------------------------------------------------------------------
; Init BASIC
			jsr _basic_init

; ---------------------------------------------------------------------------
; display boot prompt

bp:
			cli						; enable IRQ interrupts
			lda #.lobyte(bootprompt)
			ldy #.hibyte(bootprompt)
			jsr _strout
			
; ---------------------------------------------------------------------------
; Cold or Warm Start

bpdone:		jsr _input				; get char
			jsr _output				; echo
			and #$5F				; convert lowercase to uppercase
			cmp #'D'				; D ?
			beq diags				; Diagnostic
bp_skip_D:	cmp #'C'				; C ?
			bne bp_skip_C
			jmp BAS_COLDSTART		; BASIC Cold Start
bp_skip_C:	cmp #'W'				; W ?
			bne bp_skip_W
			jmp BAS_WARMSTART		; BASIC Warm Start
bp_skip_W:	cmp #'M'				; M ?
			bne bpdone
			; fall thru to monitor
			
; ---------------------------------------------------------------------------
; Enter Machine-language monitor

			; help msg
			lda #.lobyte(montxt)	; display monitor text
			ldy #.hibyte(montxt)
			jsr _strout
			
			; run the monitor
gomon:		jsr _cmon
			bra _init				; back to full init

; ---------------------------------------------------------------------------
; Diagnostics - currently unused

diags:		lda #.lobyte(diagtxt)	; display diag text
			ldy #.hibyte(diagtxt)
			jsr _strout
			bra bp					; back to boot prompt


; ---------------------------------------------------------------------------
; Maskable interrupt (IRQ) service routine

_irq_int:
            phx						; Save X register contents to stack
            tsx						; Transfer stack pointer to X
			phy						; Save Y register contents to stack
            pha						; Save accumulator contents to stack
; check for BRK instruction

            inx						; pre-increment stack
            inx						; skip X pushed on stack
            lda $100,x				; get the status register from the stack
            and #$10				; Isolate B status bit
            bne break				; If B = 1, BRK detected

			lda	VIDINTR				; check for VBLANK
			bpl	irq_exit			; branch if not
			sta	VIDINTR				; clear VBLANK interrupt

            inc $0216				; test
			bne irq_exit
			inc $0217

; ---------------------------------------------------------------------------
; Restore state and exit ISR

irq_exit:	pla						; Restore accumulator contents
			ply						; Restore Y register contents
			plx						; Restore X register contents
			; fall through to rti
; ---------------------------------------------------------------------------
; Maskable interrupt (IRQ) service routine

_nmi_int:	rti						; Return from all IRQ/NMI interrupts

; ---------------------------------------------------------------------------
; BRK detected, stop

break:		pla						; Restore accumulator contents
			ply						; Restore Y register contents
			plx						; Restore X register contents
            jmp _cmonbrk

; ---------------------------------------------------------------------------
; Message Strings

startup_msg:
.byte		" ", 10, 13, "up5k_vga starting...", 0

bootprompt:
.byte		10, 13, "D/C/W/M? ", 0

diagtxt:
.byte		10, 13, "Diagnostics not available", 0

montxt:
;.byte		10, 13, "C'MON Monitor", 10, 13
;.byte		"AAAAx - examine 128 bytes @ AAAA", 10, 13
;.byte		"AAAA@DD,DD,... - store DD bytes @ AAAA", 10, 13
;.byte		"AAAAg - go @ AAAA", 10, 13, 0
.byte		10, 10, 13, "C'MON Monitor", 10, 10, 13
.byte		"Examine: AAAAx", 10, 13
.byte		"Go     : AAAAg", 10, 13
.byte		"Modify : AAAA@DD,DD,...", 10, 10, 13
.byte		0

; ---------------------------------------------------------------------------
; table of vectors for 6502

.segment  "VECTORS"

.addr      _nmi_int					; NMI vector
.addr      _init					; Reset vector
.addr      _irq_int					; IRQ/BRK vector
