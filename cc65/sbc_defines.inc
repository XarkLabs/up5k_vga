;
; I/O and memory defines for up5k 65c02 sbc
;

;
; $F000 - $F0FF ACIA
;
.define		ACIA_CTRL   $F000		; ACIA control register location
.define		ACIA_DATA   $F001		; ACIA data register location

;
; $F100 - $F1FF SPI IP registers
;
.define		SPI0_BASE	$F100		; Offset of SPI0 IP core 
.define		SPI1_BASE	$F110		; Offset of SPI1 IP core 
.define		SPICR0		$08			; Control reg 0
.define		SPICR1		$09			; Control reg 1
.define		SPICR2		$0a			; Control reg 2
.define		SPIBR		$0b			; Baud rate reg
.define		SPISR		$0c			; Status reg
.define		SPITXDR		$0d			; TX data reg (r/w)
.define		SPIRXDR		$0e			; RX data reg (ro)
.define		SPICSR		$0f			; Chip Select reg

;
; $F200 - $F2FF gpio/sysctrl
;
.define     GPIO        $F200       ; 8-bit GPIO input/output
.define     SYSCTL      $F201       ; system control (unused)
.define     RAM0_WP     $F202       ; bit per 4KB page write-protect $0xxx - $7xxx
.define     RAM1_WP     $F203       ; bit per 4KB page write-protect $8xxx - $Fxxx

;
; $F300 - $F3FF LED PWM Driver (see iCE40 LED Driver Usage Guide)
;
.define     LEDDPWRR    $F301       ; Pulse Width Register for RED
.define     LEDDPWRG    $F302       ; Pulse Width Register for GREEN
.define     LEDDPWRB    $F303       ; Pulse Width Register for BLUE
.define     LEDDBCRR    $F305       ; Breathe On Control Register
.define     LEDDBCFR    $F306       ; Breathe Off Control Register
.define     LEDDCR0     $F308       ; Control Register 0
.define     LEDDBR      $F309       ; Pre-scale Register
.define     LEDDONR     $F30A       ; ON Time Register
.define     LEDDOFR     $F30B       ; OFF Time Register
.define     CR0_LEDEN   %10000000   ; CR0 Enable (disable/enable)
.define     CR0_FR250   %01000000   ; CR0 Flick Rate (125Hz/250Hz)
.define     CR0_OUTPOL  %00100000   ; CR0 PWM Outputs Polarity (active high/low)
.define     CR0_OUTSKEW %00010000   ; CR0 PWM Output Skew (disable/enable)
.define     CR0_QKSTOP  %00001000   ; CR0 Blinking Quick Stop (disable/enable)
.define     CR0_PWMMODE %00000100   ; CR0 PWM Mode (linear/LFSR)
.define     CR0_BRMSB   %00000011   ; CR0 mask for 2-MSB extending LEDDBR

;
; $F400 - $F4FF PS/2 keyboard
;
.define		PS2_CTRL    $F400		; PS2 control register location
.define		PS2_DATA    $F401		; PS2 data register location (ASCII)
.define		PS2_RSTA    $F402		; PS2 raw status register location
.define		PS2_RDAT    $F403		; PS2 raw data register location

;
; $F500 - $F5FF Sound generator
;
.define		SND0_BASE   $F500       ; sound voice 0
.define		SND1_BASE   $F504       ; sound voice 1
.define		SND2_BASE   $F508       ; sound voice 2
.define		SND3_BASE   $F50C       ; sound voice 3
.define     SNDFREQL    $00         ; freqency low 8-bits (buffered until high)
.define     SNDFREQH    $01         ; freqency high 8-bits (sets all 16-bits)
.define     SNDWAVEFRM  $02         ; 3-bits waveform select
.define     SNDAMPLTDE  $02         ; 8-bits amplitude

;
; $F600 - $F6FF Video hardware
;
.define     VIDCTRL     $F600       ; color mode, memory bank, glyph/color
.define     VIDHRCOLOR  $F601       ; hires foreground/background color
.define     VIDINTR     $F602       ; video interrupt enable and flag
.define     VIDCOLPAL   $F610       ; 16 entry color palette array (xxRRGGBB)
.define     VIDC_COLSEL %00000001   ; VIDCTRL 0=read/write glyph, 1=read/write color
.define     VIDC_MBANK  %00000010   ; VIDCTRL video memory bank (0/1)
.define     VIDC_CMODE  %00001100   ; VIDCTRL color mode 0=color byte, 1=hires fore/back, 2,3=bitmap
.define     VIDC_IRQENA %10000000   ; VIDCTRL IRQ interrupt generation
.define     VIDH_FOREC  %11110000   ; VIDHRCOLOR mask for forground color
.define     VIDH_BACKC  %11110000   ; VIDHRCOLOR mask for background color
.define     VIDI_INTFLG %10000000   ; VIDINTR read interrupt flag/write clear flag
