0REM http://vintage-basic.net/games.html - OSI Tweaks by Xark
10REM SUPER STARTREK - MAY 16,1978 - REQUIRES 24K MEMORY
30REM
40REM **        **** STAR TREK ****
50REM ** Simulation of a mission of the starship Enterprise,
60REM ** As seen on the Star Trek TV show.
70REM ** Original program by Mike Mayfield, modified version
80REM ** published in DEC's "101 BASIC Games", by Dave Ahl.
90REM ** Modifications to the latter (plus debugging) by Bob
100REM * Leedom - April & December 1974,
110REM * with a little help from his friends . . .
120REM * Comments, epithets, and suggestions solicited --
130REM * SEND TO:  R. C. Leedom
140REM *           Westinghouse Defense & Electronics Systems Cntr.
150REM *           Box 746, M.S. 338
160REM *           Baltimore, MD  21203
170REM *
180REM * Converted to Microsoft 8K BASIC 3/16/78 by John Gorders
190REM * Line numbers from version STREK7 OF 1/12/75 preserved as
200REM * much as possible while using multiple statements per line
205REM * Some lines are longer than 72 characters; this was done
210REM * by using "?" instead of "?" when entering lines
215REM *
220?:?:?:?:?:?:?:?:?:?:?
221?"                                    ,------*------,"
222?"                    ,-------------   '---  ------'"
223?"                     '-------- --'      / /"
224?"                         ,---' '-------/ /--,"
225?"                          '----------------'":?
226?"                    The USS Enterprise --- NCC-1701"
227?:?:?:?:?
260REM CLEAR 600
270Z$="                         "
274SX$="<E>":SK$="+K+":SB$=">B<"
275REM SX$=" "+CHR$(11)+CHR$(12):SK$=" "+CHR$(213)+CHR$(212)
276REM SB$=CHR$(179)+CHR$(232)+CHR$(182)
330DIM G(8,8),C(9,2),K(3,3),N(3),Z(8,8),D(8)
370T=INT(RND(1)*20+20)*100:T0=T:T9=25+INT(RND(1)*10):D0=0:E=3000:E0=E
440P=10:P0=P:S9=200:S=0:B9=2:K9=0:X$="":X0$=" IS "
470DEF FND(D)=SQR((K(I,1)-S1)^2+(K(I,2)-S2)^2)
475DEF FNR(R)=INT(RND(R)*7.98+1.01)
480REM INITIALIZE ENTERPRIZE'S POSITION
490Q1=FNR(1):Q2=FNR(1):S1=FNR(1):S2=FNR(1)
530FORI=1TO9:C(I,1)=0:C(I,2)=0:NEXT
540C(3,1)=-1:C(2,1)=-1:C(4,1)=-1:C(4,2)=-1:C(5,2)=-1:C(6,2)=-1
600C(1,2)=1:C(2,2)=1:C(6,1)=1:C(7,1)=1:C(8,1)=1:C(8,2)=1:C(9,2)=1
670FORI=1TO8:D(I)=0:NEXT
710A1$="NAVSRSLRSPHATORSHEDAMCOMXXX"
810REM SETUP WHAT EXHISTS IN GALAXY . . .
815REM K3= # KLINGONS  B3= # STARBASES  S3 = # STARS
820FORI=1TO8:FORJ=1TO8:K3=0:Z(I,J)=0:R1=RND(1)
850IFR1>.98THENK3=3:K9=K9+3:GOTO980
860IFR1>.95THENK3=2:K9=K9+2:GOTO980
870IFR1>.80THENK3=1:K9=K9+1
980B3=0:IFRND(1)>.96THENB3=1:B9=B9+1
1040G(I,J)=K3*100+B3*10+FNR(1):NEXT:NEXT:IFK9>T9THENT9=K9+1
1100IFB9<>0THEN1200
1150IFG(Q1,Q2)<200THENG(Q1,Q2)=G(Q1,Q2)+120:K9=K9+1
1160B9=1:G(Q1,Q2)=G(Q1,Q2)+10:Q1=FNR(1):Q2=FNR(1)
1200K7=K9:IFB9<>1THENX$="s":X0$=" are "
1230?"Your orders are as follows:"
1240?"     Destroy the";K9;"Klingon warships which have invaded"
1252?"   the galaxy before they can attack Federation headquarters"
1260?"   on stardate";T0+T9;"  This gives you";T9;"days.  There";X0$
1272?"  ";B9;"starbase";X$;" in the galaxy for resupplying your ship."
1280?:REM ?"Press a key when ready to accept command:": WAIT 62464,1
1300I=RND(1):REM IF INP(1)=13 THEN 1300
1310REM HERE ANY TIME NEW QUADRANT ENTERED
1320Z4=Q1:Z5=Q2:K3=0:B3=0:S3=0:G5=0:D4=.5*RND(1):Z(Q1,Q2)=G(Q1,Q2)
1390IFQ1<1ORQ1>8ORQ2<1ORQ2>8THEN1600
1430GOSUB 9030:?:IF T0<>T THEN 1490
1460?"Your mission begins with your starship located"
1470?"in the galactic quadrant, '";G2$;"'.":GOTO 1500
1490?"Now entering ";G2$;" quadrant . . ."
1500?:K3=INT(G(Q1,Q2)*.01):B3=INT(G(Q1,Q2)*.1)-10*K3
1540S3=G(Q1,Q2)-100*K3-10*B3:IFK3=0THEN1590
1560?"Combat Area      Condition RED":IFS>200THEN1590
1580?"   Shields dangerously low"
1590FORI=1TO3:K(I,1)=0:K(I,2)=0:NEXT
1600FORI=1TO3:K(I,3)=0:NEXT:Q$=Z$+Z$+Z$+Z$+Z$+Z$+Z$+LEFT$(Z$,17)
1660REM POSITION ENTERPRISE IN QUADRANT, THEN PLACE "K3" KLINGONS, &
1670REM "B3" STARBASES, & "S3" STARS ELSEWHERE.
1680A$=SX$:Z1=S1:Z2=S2:GOSUB8670:IFK3<1THEN1820
1720FORI=1TOK3:GOSUB8590:A$=SK$:Z1=R1:Z2=R2
1780GOSUB8670:K(I,1)=R1:K(I,2)=R2:K(I,3)=S9*(0.5+RND(1)):NEXT
1820IFB3<1THEN1910
1880GOSUB8590:A$=SB$:Z1=R1:B4=R1:Z2=R2:B5=R2:GOSUB8670
1910FORI=1TOS3:GOSUB8590:A$=" * ":Z1=R1:Z2=R2:GOSUB8670:NEXT
1980GOSUB6430
1990IFS+E>10THENIFE>10ORD(7)=0THEN2060
2020?:?"** FATAL ERROR **   You've just stranded your ship in "
2030?"space":?"You have insufficient maneuvering energy,";
2040?" and shield control":?"is presently incapable of cross";
2050?"-circuiting to engine room!!":GOTO6220
2060INPUT"Command";A$
2080FORI=1TO9:IFLEFT$(A$,3)<>MID$(A1$,3*I-2,3)THEN2160
2140ONIGOTO2300,1980,4000,4260,4700,5530,5690,7290,6270
2160NEXT:?"Enter one of the following:"
2180?"  NAV  (To set course)"
2190?"  SRS  (For short range sensor scan)"
2200?"  LRS  (For long range sensor scan)"
2210?"  PHA  (To fire phasers)"
2220?"  TOR  (To fire photon torpedoes)"
2230?"  SHE  (To raise or lower shields)"
2240?"  DAM  (FOr damage control reports)"
2250?"  COM  (To call on library-computer)"
2260?"  XXX  (To resign your command)":?:GOTO 1990
2290REM COURSE CONTROL BEGINS HERE
2300GOSUB2575:INPUT"Course (0-9)";C1:IFC1=9THENC1=1
2310IFC1>=1ANDC1<9THEN2350
2330?"   Lt. Sulu reports, 'Incorrect course data, sir!'":GOTO1990
2350X$="8":IFD(1)<0THENX$="0.2"
2360?"Warp factor, 1.0 = one quadrant."
2365?"(0-";X$;")";:INPUTW1:IFD(1)<0ANDW1>.2THEN2470
2380IFW1>0ANDW1<=8THEN2490
2390IFW1=0THEN1990
2420?"   chief engineer Scott reports 'The engines won't take";
2430?" warp ";W1;"!'":GOTO1990
2470?"Warp engines are damaged.  Maxium speed = Warp 0.2":GOTO1990
2490N=INT(W1*8+.5):IFE-N>=0THEN2590
2500?"Engineering reports   'Insufficient energy available"
2510?"                       for maneuvering at warp";W1;"!'"
2530IFS<N-EORD(7)<0THEN1990
2550?"Deflector control room acknowledges";S;"units of energy"
2560?"                         presently deployed to shields."
2570GOTO1990
2575?"   4  3  2":?"    \ | /":?"     \|/":?" 5 ---*--- 1"
2578?"     /|\":?"    / | \":?"   6  7  8":RETURN
2580REM KLINGONS MOVE/FIRE ON MOVING STARSHIP . . .
2590FORI=1TOK3:IFK(I,3)=0THEN2700
2610A$="   ":Z1=K(I,1):Z2=K(I,2):GOSUB8670:GOSUB8590
2660K(I,1)=Z1:K(I,2)=Z2:A$=SK$:GOSUB8670
2700NEXT:GOSUB6000:D1=0:D6=W1:IFW1>=1THEND6=1
2770FORI=1TO8:IFD(I)>=0THEN2880
2790D(I)=D(I)+D6:IFD(I)>-.1ANDD(I)<0THEND(I)=-.1:GOTO2880
2800IFD(I)<0THEN2880
2810IFD1<>1THEND1=1:?"Damage Control Report:  ";
2840?TAB(8);:R1=I:GOSUB8790:?G2$;" Repair completed."
2880NEXT:IFRND(1)>.2THEN3070
2910R1=FNR(1):IFRND(1)>=.6THEN3000
2930D(R1)=D(R1)-(RND(1)*5+1):?"Damage Control Report:  ";
2960GOSUB8790:?G2$;" damaged":?:GOTO3070
3000D(R1)=D(R1)+RND(1)*3+1:?"Damage Control Report:  ";
3030GOSUB8790:?G2$;" State of repair improved":?
3060REM BEGIN MOVING STARSHIP
3070A$="   ":Z1=INT(S1):Z2=INT(S2):GOSUB8670
3110X1=C(C1,1)+(C(C1+1,1)-C(C1,1))*(C1-INT(C1)):X=S1:Y=S2
3140X2=C(C1,2)+(C(C1+1,2)-C(C1,2))*(C1-INT(C1)):Q4=Q1:Q5=Q2
3170FORI=1TON:S1=S1+X1:S2=S2+X2:IFS1<1ORS1>=9ORS2<1ORS2>=9THEN3500
3240S8=INT(S1)*24+INT(S2)*3-26:IFMID$(Q$,S8,2)="  "THEN3360
3320S1=INT(S1-X1):S2=INT(S2-X2):?"Warp engines shut down at ";
3350?"sector";S1;",";S2;"Due to bad navagation":GOTO3370
3360NEXT:S1=INT(S1):S2=INT(S2)
3370A$=SX$:Z1=INT(S1):Z2=INT(S2):GOSUB8670:GOSUB3910:T8=1
3430IFW1<1THENT8=.1*INT(10*W1)
3450T=T+T8:IFT>T0+T9THEN6220
3470REM SEE IF DOCKED, THEN GET COMMAND
3480GOTO1980
3490REM EXCEEDED QUADRANT LIMITS
3500X=8*Q1+X+N*X1:Y=8*Q2+Y+N*X2:Q1=INT(X/8):Q2=INT(Y/8):S1=INT(X-Q1*8)
3550S2=INT(Y-Q2*8):IFS1=0THENQ1=Q1-1:S1=8
3590IFS2=0THENQ2=Q2-1:S2=8
3620X5=0:IFQ1<1THENX5=1:Q1=1:S1=1
3670IFQ1>8THENX5=1:Q1=8:S1=8
3710IFQ2<1THENX5=1:Q2=1:S2=1
3750IFQ2>8THENX5=1:Q2=8:S2=8
3790IFX5=0THEN3860
3800?"Lt. Uhura reports message from Starfleet command:"
3810?"  'Permission to attempt crossing of galactic perimeter"
3820?"  is hereby *DENIED*.  Shut down your engines.'"
3830?"Chief engineer Scott reports  'Warp engines shut down"
3840?"  at sector";S1;",";S2;"of quadrant";Q1;",";Q2;".'"
3850IFT>T0+T9THEN6220
3860IF8*Q1+Q2=8*Q4+Q5THEN3370
3870T=T+1:GOSUB3910:GOTO1320
3900REM MANEUVER ENERGY S/R **
3910E=E-N-10:IFE>=0THENRETURN
3930?"Shield control supplies energy to complete the maneuver."
3940S=S+E:E=0:IFS<=0THENS=0
3980RETURN
3990REM LONG RANGE SENSOR SCAN CODE
4000IFD(3)<0THEN?"Long range sensors are inoperable":GOTO1990
4030?"Long range scan for quadrant";Q1;",";Q2
4040O1$="-------------------":?O1$
4060FORI=Q1-1TOQ1+1:N(1)=-1:N(2)=-2:N(3)=-3:FORJ=Q2-1TOQ2+1
4120IFI>0ANDI<9ANDJ>0ANDJ<9THENN(J-Q2+2)=G(I,J):Z(I,J)=G(I,J)
4180NEXT:FORL=1TO3:?": ";:IFN(L)<0THEN?"*** ";:GOTO4230
4210?RIGHT$(STR$(N(L)+1000),3);" ";
4230NEXT:?":":?O1$:NEXT:GOTO1990
4250REM PHASER CONTROL CODE BEGINS HERE
4260IFD(4)<0THEN?"Phasers inoperative":GOTO1990
4265IFK3>0THEN4330
4270?"Science officer Spock reports  'Sensors show no enemy ships"
4280?"                                in this quadrant'":GOTO1990
4330IFD(8)<0THEN?"Computer failure hampers accuracy"
4350?"Phasers locked on target;  ";
4360?"Energy available =";E;"units"
4370INPUT"Number of units to fire";X:IFX<=0THEN1990
4400IFE-X<0THEN4360
4410E=E-X:IFD(7)<0THENX=X*RND(1)
4450H1=INT(X/K3):FORI=1TO3:IFK(I,3)<=0THEN4670
4480H=INT((H1/FND(0))*(RND(1)+2)):IFH>.15*K(I,3)THEN4530
4500?"Sensors show no damage to enemy at ";K(I,1);",";K(I,2):GOTO4670
4530K(I,3)=K(I,3)-H:?H;"Unit hit on Klingon at sector";K(I,1);",";
4550?K(I,2):IFK(I,3)<=0THEN?"*** Klingon destroyed ***":GOTO4580
4560?"   (Sensors show";K(I,3);"units remaining)":GOTO4670
4580K3=K3-1:K9=K9-1:Z1=K(I,1):Z2=K(I,2):A$="   ":GOSUB8670
4650K(I,3)=0:G(Q1,Q2)=G(Q1,Q2)-100:Z(Q1,Q2)=G(Q1,Q2):IFK9<=0THEN6370
4670NEXT:GOSUB6000:GOTO1990
4690REM PHOTON TORPEDO CODE BEGINS HERE
4700IFP<=0THEN?"All photon torpedoes expended":GOTO 1990
4730IFD(5)<0THEN?"Photon tubes are not operational":GOTO1990
4760GOSUB2575:INPUT"Photon torpedo course (1-9)";C1:IFC1=9THENC1=1
4780IFC1>=1ANDC1<9THEN4850
4790?"Ensign Chekov reports,  'Incorrect course data, sir!'"
4800GOTO1990
4850X1=C(C1,1)+(C(C1+1,1)-C(C1,1))*(C1-INT(C1)):E=E-2:P=P-1
4860X2=C(C1,2)+(C(C1+1,2)-C(C1,2))*(C1-INT(C1)):X=S1:Y=S2
4910?"Torpedo track:"
4920X=X+X1:Y=Y+X2:X3=INT(X+.5):Y3=INT(Y+.5)
4960IFX3<1ORX3>8ORY3<1ORY3>8THEN5490
5000?"               ";X3;",";Y3:A$="   ":Z1=X:Z2=Y:GOSUB8830
5050IFZ3<>0THEN4920
5060A$=SK$:Z1=X:Z2=Y:GOSUB8830:IFZ3=0THEN5210
5110?"*** Klingon destroyed ***":K3=K3-1:K9=K9-1:IFK9<=0THEN6370
5150FORI=1TO3:IFX3=K(I,1)ANDY3=K(I,2)THEN5190
5180NEXT:I=3
5190K(I,3)=0:GOTO5430
5210A$=" * ":Z1=X:Z2=Y:GOSUB8830:IFZ3=0THEN5280
5260?"Star at";X3;",";Y3;"absorbed torpedo energy.":GOSUB6000:GOTO1990
5280A$=SB$:Z1=X:Z2=Y:GOSUB8830:IFZ3=0THEN4760
5330?"*** Starbase destroyed ***":B3=B3-1:B9=B9-1
5360IFB9>0ORK9>T-T0-T9THEN5400
5370?"That does it, Captain!!  You are hereby relieved of command"
5380?"and sentenced to 99 stardates at hard labor on Cygnus 12!!"
5390GOTO 6270
5400?"Starfleet command reviewing your record to consider"
5410?"court martial!":D0=0
5430Z1=X:Z2=Y:A$="   ":GOSUB8670
5470G(Q1,Q2)=K3*100+B3*10+S3:Z(Q1,Q2)=G(Q1,Q2):GOSUB6000:GOTO1990
5490?"Torpedo missed":GOSUB6000:GOTO1990
5520REM SHIELD CONTROL
5530IFD(7)<0THEN?"Shield control inoperable":GOTO1990
5560?"Energy available =";E+S;:INPUT"Number of units to shields";X
5580IFX<0ORS=XTHEN?"<Shields unchanged>":GOTO1990
5590IFX<=E+STHEN5630
5600?"Shield control reports  'This is not the federation treasury.'"
5610?"<Shields unchanged>":GOTO1990
5630E=E+S-X:S=X:?"Deflector control room report:"
5660?"  'Shields now at";INT(S);"units per your command.'":GOTO1990
5680REM DAMAGE CONTROL
5690IFD(6)>=0THEN5910
5700?"Damage control report not available":IFD0=0THEN1990
5720D3=0:FORI=1TO8:IFD(I)<0THEND3=D3+.1
5760NEXT:IFD3=0THEN1990
5780?:D3=D3+D4:IFD3>=1THEND3=.9
5810?"Technicians standing by to effect repairs to your ship;"
5820?"Estimated time to repair:";.01*INT(100*D3);"stardates"
5840INPUT "Will you authorize the repair order (Y/N)";A$
5860IFA$<>"Y"THEN 1990
5870FORI=1TO8:IFD(I)<0THEND(I)=0
5890NEXT:T=T+D3+.1
5910?:?"Device             State of repair":FORR1=1TO8
5920GOSUB8790:?G2$;LEFT$(Z$,25-LEN(G2$));INT(D(R1)*100)*.01
5950NEXT:?:IFD0<>0THEN5720
5980GOTO 1990
5990REM KLINGONS SHOOTING
6000IFK3<=0THENRETURN
6010IFD0<>0THEN?"Starbase shields protect the Enterprise":RETURN
6040FORI=1TO3:IFK(I,3)<=0THEN6200
6060H=INT((K(I,3)/FND(1))*(2+RND(1))):S=S-H:K(I,3)=K(I,3)/(3+RND(0))
6080?H;"Unit hit on Enterprise from sector";K(I,1);",";K(I,2)
6090IFS<=0THEN6240
6100?"      <Shields down to";S;"units>":IFH<20THEN6200
6120IFRND(1)>.6ORH/S<=.02THEN6200
6140R1=FNR(1):D(R1)=D(R1)-H/S-.5*RND(1):GOSUB8790
6170?"Damage control reports '";G2$;" damaged by the hit'"
6200NEXT:RETURN
6210REM END OF GAME
6220?"It is stardate";T:GOTO 6270
6240?:?"The Enterprise has been destroyed.  The federation ";
6250?"will be conquered.":GOTO 6220
6270?"There were";K9;"Klingon battle cruisers left at"
6280?"the end of your mission."
6290?:?:IFB9=0THEN6360
6310?"The Federation is in need of a new starship commander"
6320?"for a similar mission -- If there is a volunteer,"
6330INPUT"let him step forward and enter 'AYE'";A$:IFA$="AYE"THENRUN
6360END
6370?"Congrulation, Captain!  The last Klingon battle cruiser"
6380?"menacing the Federation has been destroyed.":?
6400?"Your efficiency rating is:";1000*(K7/(T-T0))^2:GOTO6290
6420REM SHORT RANGE SENSOR SCAN & STARTUP SUBROUTINE
6430FORI=S1-1TOS1+1:FORJ=S2-1TOS2+1
6450IFINT(I+.5)<1ORINT(I+.5)>8ORINT(J+.5)<1ORINT(J+.5)>8THEN6540
6490A$=SB$:Z1=I:Z2=J:GOSUB8830:IFZ3=1THEN6580
6540NEXT:NEXT:D0=0:GOTO6650
6580D0=1:C$="Docked":E=E0:P=P0
6620?"Shields dropped for docking purposes":S=0:GOTO6720
6650IFK3>0THENC$="=RED=":GOTO6720
6660C$="Green":IFE<E0*.1THENC$="Yellow"
6720IFD(2)>=0THEN6770
6730?:?"*** Short range sensors are out ***":?:RETURN
6770O1$="---------------------------------":?O1$:FORI=1TO8
6820FORJ=(I-1)*24+1TO(I-1)*24+22STEP3:?" ";MID$(Q$,J,3);:NEXT
6830ONIGOTO6850,6900,6960,7020,7070,7120,7180,7240
6850?"        Stardate          ";INT(T*10)*.1:GOTO7260
6900?"        Condition          ";C$:GOTO7260
6960?"        Quadrant          ";Q1;",";Q2:GOTO7260
7020?"        Sector            ";S1;",";S2:GOTO7260
7070?"        Photon Torpedoes  ";INT(P):GOTO7260
7120?"        Total Energy      ";INT(E+S):GOTO7260
7180?"        Shields           ";INT(S):GOTO7260
7240?"        Klingons Remaining";INT(K9)
7260NEXT:?O1$:RETURN
7280REM LIBRARY COMPUTER CODE
7290IFD(8)<0THEN?"Computer disabled":GOTO1990
7320?"Computer active and awaiting command"
7325INPUT"(0=Galaxy 1=Status 2=Torp 3=Base 4=Calc 5=Map 6=Help)";A
7330IFA<0THEN1990
7350?:H8=1:ONA+1GOTO7540,7900,8070,8500,8150,7400
7360?"Functions available from library-computer:"
7370?"   0 = Cumulative galactic record"
7372?"   1 = Status report"
7374?"   2 = Photon torpedo data"
7376?"   3 = Starbase nav data"
7378?"   4 = Direction/distance calculator"
7380?"   5 = Galaxy 'region name' map":?:GOTO7320
7390REM SETUP TO CHANGE CUM GAL RECORD TO GALAXY MAP
7400H8=0:G5=1:?"                        The Galaxy":GOTO7550
7530REM CUM GALACTIC RECORD
7540REM
7543?:?"        ";
7544?"Computer record of galaxy for quadrant";Q1;",";Q2
7546?
7550?"       1     2     3     4     5     6     7     8"
7560O1$="     ----- ----- ----- ----- ----- ----- ----- -----"
7570?O1$:FORI=1TO8:?I;:IFH8=0THEN7740
7630FORJ=1TO8:?"   ";:IFZ(I,J)=0THEN?"***";:GOTO7720
7700?RIGHT$(STR$(Z(I,J)+1000),3);
7720NEXT:GOTO7850
7740Z4=I:Z5=1:GOSUB9030:J0=INT(15-.5*LEN(G2$)):?TAB(J0);G2$;
7800Z5=5:GOSUB 9030:J0=INT(39-.5*LEN(G2$)):?TAB(J0);G2$;
7850?:?O1$:NEXT:?:GOTO1990
7890REM STATUS REPORT
7900? "   Status report:":X$="":IFK9>1THENX$="s"
7940?"Klingon";X$;" Left: ";K9
7960?"Mission must be completed in";.1*INT((T0+T9-T)*10);"stardates"
7970X$="s":IFB9<2THENX$="":IFB9<1THEN8010
7980?"The Federation is maintaining";B9;"starbase";X$;" in the galaxy"
7990GOTO5690
8010?"Your stupidity has left you on your own in"
8020?"  the galaxy -- you have no starbases left!":GOTO5690
8060REM TORPEDO, BASE NAV, D/D CALCULATOR
8070IFK3<=0THEN4270
8080X$="":IFK3>1THENX$="s"
8090?"From Enterprise to Klingon battle cruser";X$
8100H8=0:FORI=1TO3:IFK(I,3)<=0THEN8480
8110W1=K(I,1):X=K(I,2)
8120C1=S1:A=S2:GOTO8220
8150?"Direction/distance calculator:"
8160?"You are at quadrant ";Q1;",";Q2;" Sector ";S1;",";S2
8170?"Please enter":INPUT"  initial coordinates (X,Y)";C1,A
8200INPUT"  Final coordinates (X,Y)";W1,X
8220X=X-A:A=C1-W1:IFX<0THEN8350
8250IFA<0THEN8410
8260IFX>0THEN8280
8270IFA=0THENC1=5:GOTO8290
8280C1=1
8290IFABS(A)<=ABS(X)THEN8330
8310?"Direction =";C1+(((ABS(A)-ABS(X))+ABS(A))/ABS(A)):GOTO8460
8330?"Direction =";C1+(ABS(A)/ABS(X)):GOTO8460
8350IFA>0THENC1=3:GOTO8420
8360IFX<>0THENC1=5:GOTO8290
8410C1=7
8420IFABS(A)>=ABS(X)THEN8450
8430?"Direction =";C1+(((ABS(X)-ABS(A))+ABS(X))/ABS(X)):GOTO8460
8450?"Direction =";C1+(ABS(X)/ABS(A))
8460?"Distance =";SQR(X^2+A^2):IFH8=1THEN1990
8480NEXT:GOTO1990
8500IFB3<>0THEN?"From Enterprise to starbase:":W1=B4:X=B5:GOTO8120
8510?"Mr. Spock reports,  'Sensors show no starbases in this";
8520?" quadrant.'":GOTO1990
8580REM FIND EMPTY PLACE IN QUADRANT (FOR THINGS)
8590R1=FNR(1):R2=FNR(1):A$="   ":Z1=R1:Z2=R2:GOSUB8830:IFZ3=0THEN8590
8600RETURN
8660REM INSERT IN STRING ARRAY FOR QUADRANT
8670S8=INT(Z2-.5)*3+INT(Z1-.5)*24+1
8675IF LEN(A$)<>3THEN ?"ERROR":STOP
8680IFS8=1THENQ$=A$+RIGHT$(Q$,189):RETURN
8690IFS8=190THENQ$=LEFT$(Q$,189)+A$:RETURN
8700Q$=LEFT$(Q$,S8-1)+A$+RIGHT$(Q$,190-S8):RETURN
8780REM ?S DEVICE NAME
8790ONR1GOTO8792,8794,8796,8798,8800,8802,8804,8806
8792G2$="Warp engines":RETURN
8794G2$="Short range sensors":RETURN
8796G2$="Long range sensors":RETURN
8798G2$="Phaser control":RETURN
8800G2$="Photon tubes":RETURN
8802G2$="Damage control":RETURN
8804G2$="Shield control":RETURN
8806G2$="Library-computer":RETURN
8820REM STRING COMPARISON IN QUADRANT ARRAY
8830Z1=INT(Z1+.5):Z2=INT(Z2+.5):S8=(Z2-1)*3+(Z1-1)*24+1:Z3=0
8890IFMID$(Q$,S8,3)<>A$THENRETURN
8900Z3=1:RETURN
9010REM QUADRANT NAME IN G2$ FROM Z4,Z5 (=Q1,Q2)
9020REM CALL WITH G5=1 TO GET REGION NAME ONLY
9030IFZ5<=4THENONZ4GOTO9040,9050,9060,9070,9080,9090,9100,9110
9035GOTO9120
9040G2$="Antares":GOTO9210
9050G2$="Rigel":GOTO9210
9060G2$="Procyon":GOTO9210
9070G2$="Vega":GOTO9210
9080G2$="Canopus":GOTO9210
9090G2$="Altair":GOTO9210
9100G2$="Sagittarius":GOTO9210
9110G2$="Pollux":GOTO9210
9120ONZ4GOTO9130,9140,9150,9160,9170,9180,9190,9200
9130G2$="Sirius":GOTO9210
9140G2$="Deneb":GOTO9210
9150G2$="Capella":GOTO9210
9160G2$="Betelgeuse":GOTO9210
9170G2$="Aldebaran":GOTO9210
9180G2$="Regulus":GOTO9210
9190G2$="Arcturus":GOTO9210
9200G2$="Spica"
9210IFG5<>1THENONZ5GOTO9230,9240,9250,9260,9230,9240,9250,9260
9220RETURN
9230G2$=G2$+" I":RETURN
9240G2$=G2$+" II":RETURN
9250G2$=G2$+" III":RETURN
9260G2$=G2$+" IV":RETURN
