#! /bin/bash
OUT=basic_programs.rom
DIR=00_directory.txt
BLANK=blank.bin
BASIC_PROGS=*.bas
TMPFILE=$(mktemp)
rm -f $BLANK $OUT $DIR
# Make 32KB "blank" entry full of 0xff
echo -ne "\xff" >$BLANK
BLANKSIZE=1
while [ $BLANKSIZE -ne 32768 ]
do
	cat $BLANK $BLANK >$TMPFILE
	mv -f $TMPFILE $BLANK
	((BLANKSIZE=BLANKSIZE+BLANKSIZE))
done
echo -e >> $DIR "\r"
echo -e >> $DIR "NEW\r"
echo -e >> $DIR "10 ?:?\"BASIC program directory:\":?:Q\$=CHR\$(34):\r"
echo -e >> $DIR "100 ?\"LOAD\";0,Q\$;\"00_directory.bas\";Q\$,\"(this file)\"\r"
LINE=110
SLOT=1
for f in $BASIC_PROGS
do
	if [[ "$OSTYPE" == "darwin"* ]]; then
		FILESIZE=$(stat -f "%z" "$f")
	else
		FILESIZE=$(stat -c "%s" "$f")
	fi
	echo -e >> $DIR "$LINE ?\"LOAD\";$SLOT,Q\$;\"$f\";Q\$,\"(bytes $FILESIZE)\"\r"
	cat $BLANK >> $OUT
	((SLOT++))
	((LINE=LINE+10)) 
done
echo -e >> $DIR "$LINE ?:?\"Enter \";Q\$;\"LOAD #\";Q\$;\" (with # from above list).\"\r"
echo -e >> $DIR "999 NEW\r"
echo -e >> $DIR "RUN\r"
echo "BASIC program directory saved in LOAD 0 slot:"
SLOT=0
for f in $DIR $BASIC_PROGS
do
	if [[ "$OSTYPE" == "darwin"* ]]; then
		FILESIZE=$(stat -f "%z" "$f")
	else
		FILESIZE=$(stat -c "%s" "$f")
	fi
	echo -e "LOAD $SLOT\t\"$f\" ($FILESIZE bytes)"
	dd  2>/dev/null conv=notrunc,sparse bs=32768 of=$OUT seek=$SLOT if=$f
	((SLOT++)) 
done
rm -f $BLANK
