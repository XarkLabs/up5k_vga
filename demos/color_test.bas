
 10 REM TEST COLOR
 15 POKE 62976, 1
 16 J = 100
 17 K = 6.25
 18 L = 53248
 20 FOR X = 0 TO 3699
 25 C = INT((X - J * INT(X/J))/K)
 30 POKE L+X,C
 40 NEXT X
 45 POKE 62976, 0
 50 PRINT "I,R,G,B";
 60 INPUT I, R, G, B
 70 POKE 62992+I, R*16+G*4+B
 80 GOTO 50