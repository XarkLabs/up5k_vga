
 100 REM A BASIC, COLOR MANDELBROT
 110 REM
 120 REM This implementation copyright (c) 2019, Gordon Hendrson
 130 REM
 140 REM Permission to use/abuse anywhere for any purpose grated, but
 150 REM it comes with no warranty whatsoever. Good luck!
 160 REM
 170 POKE 62976, 8
 172 FORX=0TO7500:POKE53248+X,255:NEXT
 173 POKE 62976,9
 174 FORX=0TO7500:POKE53248+X,255:NEXT
 175 MC = 0
 180 SO = 0
 190 MI = 15
 200 MX = 4
 210 LS = -2.0
 220 TP = 1.25
 230 XS = 2.5
 240 YS = -2.5
 250 W = 199
 260 H = 149
 270 SX = XS / W
 280 SY = YS / H
 290 POKE 62976, 1
 300 FOR Y = 0 TO H
 310 CY = Y * SY + TP
 320 FOR X = 0 TO W
 330 CX = X * SX + LS
 340 ZX = 0
 350 ZY = 0
 360 CC = SO
 370 X2 = ZX * ZX
 380 Y2 = ZY * ZY
 390 IF CC > MI THEN GOTO 460
 400 IF (X2 + Y2) > MX THEN GOTO 460
 410 T = X2 - Y2 + CX
 420 ZY = 2 * ZX * ZY + CY
 430 ZX = T
 440 CC = CC + 1
 450 GOTO 370
 460 C = 16-CC : GOSUB 1000
 465 GOSUB 2000
 470 NEXT
 480 NEXT
 490 GOSUB 2000
 500 GOTO 490
 510 END
 1000 REM PLOT A PIXEL AT X,Y COLOR C
 1010 V = INT(X/2)+INT(Y/2)*100 + 53248
 1020 S = 1 + 15*(XAND1)
 1030 B = C * S
 1035 M = 255-(15*S)
 1040 POKE 62976,8+(YAND1)
 1045 D = PEEK(V) AND M
 1050 POKE V, D OR B
 1060 RETURN
 2000 REM CYCLE COLOR ZERO
 2010 POKE 62992, MC
 2020 MC = 63 AND (MC + 1)
 2030 RETURN