
 10 REM TEST VGA GRAPHICS MODE WITH CIRCLES
 20 POKE 62976, 8
 29 FOR Y = 0 TO 1
 30 FOR X = 0 TO 8191:POKE 53248+X,0:NEXT
 31 POKE 62976,9
 32 NEXT
 40 FOR X = 0 TO 150
 50 Y = X
 60 GOSUB 1000
 70 NEXT X
 80 INPUT A
 90 POKE 62976, 0
 100 END
 1000 REM PLOT A PIXEL AT X,Y
 1010 V = INT(X/4)+INT(Y/4)*100 + 53248
 1020 S = 1 + 15 * (YAND1)
 1030 B = 2^(3-(XAND3)) * S
 1040 POKE 62976,8+((YAND2)/2)
 1050 POKE V, PEEK(V) OR B
 1060 RETURN