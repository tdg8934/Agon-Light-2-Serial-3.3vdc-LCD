   10 REM SERIAL SEND EXAMPLE
   20 REM RICHARD TURNNIDGE 2023
   21 REM This version is for 16-bit basic but you could adapt
   22 REM Check if we are running in 24-bit BASIC
   24 :
   25 IF HIMEM > &FFFF PRINT "This code will only run on BBC BASIC for Z80": STOP
   30 :
   31 REM ---------------------------------------------------------
   32 REM This is the user assembly code 
   33 REM ---------------------------------------------------------
   36 :
   38 REM allocate plenty of memory spaces for the three machine code commands
   39 :
   40 DIM openuart% 64
   50 DIM closeuart% 64
   60 DIM senduart% 64
   70 :
   90 REM This routine is for opening the uart
  100 FOR I%=0 TO 3 STEP 3
  110   P%=openuart%
  120   [
  130   OPT I%
  140   :
  150   LD IX, uartstruct ; Address of the uart struct
  160   ld a, &15
  170   RST &08 ; mos_uopen
  180   RET
  190   .uartstruct
  200   DEFB &80 ; LONG (3 bytes) to store baud rate (9600)
  210   DEFB &25
  220   DEFB &00
  230   DEFB 8 ; data bits
  240   DEFB 1 ; stop bits
  250   DEFB 0 ; parity bits
  260   DEFB 0 ; flow control
  270   DEFB 0 ; interrupt bits
  280   ]
  290 NEXT
 1000 :
 1010 REM This routine is to close the uart
 1080 FOR I%=0 TO 3 STEP 3
 1090   P%=closeuart%
 1100   [
 1110   OPT I%
 1120   :
 1210   ld a, &16
 1220   RST &08 ; mos_uclose
 1330   RET
 1370   ]
 1480 NEXT
 1500 :
 2000 REM This routine is to send uart data
 2080 FOR I%=0 TO 3 STEP 3
 2090   P%=senduart%
 2100   [
 2110   OPT I%
 2120   :
 2210   ld c, 65 ; char to send is stored here
 2215   ld a, &18
 2220   RST &08 ; mos_uputc
 2330   RET
 2370   ]
 2480 NEXT
 2490 :
 5000 REM --------------------------------------------------------------
 5010 REM This is the user Basic program - Demo of a serial LCD (3.3vdc)
 5020 REM --------------------------------------------------------------
 5030 A = senduart% +1 : REM this is second byte into the routine, store char to send here
 5040 CALL openuart%
 5050 :
 5060 ?A = 124 : REM LCD Settings Mode
 5070 CALL senduart%
 5080 ?A = 45 : REM LCD Clear the LCD & move cursor to home
 5090 CALL senduart%
 5095 FOR D = 1 TO 1000 : NEXT : REM Delay at least 500mS to ensure splash screen has cleared before sending data
 5100 CLS
 5110 PRINT"(1) Send a message to the LCD"
 5120 PRINT"(2) TBD"
 5130 PRINT"(3) Exit the program"
 5140 INPUT M
 5150 IF M = 1 THEN GOTO 5500
 5160 REM IF M = 2 THEN ?A = 18 : CALL senduart% : ?A = 84 : CALL senduart% : GOTO 5100
 5170 IF M <> 1 OR M <> 2 THEN GOTO 5999
 5500 CLS : REM Just to make screen clear
 5510 PRINT "Serial LCD (3.3VDC) uart send example."
 5520 PRINT "There are 16 | 20 characters per line."
 5530 PRINT
 5560 INPUT "Type a message to the serial LCD: " S$
 5570 FOR S = 1 TO LEN(S$)
 5580   ?A = ASC(MID$(S$,S,1))
 5590   CALL senduart% : REM send the data byte
 5600 NEXT
 5610 :
 5670 GOTO 5100
 5999 CALL closeuart%
