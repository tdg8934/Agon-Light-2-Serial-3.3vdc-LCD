   10 REM SERIAL I2C EXAMPLE
   20 REM TIMOTHY GILMORE 2024 / ADAPTED UART CODE BY RICHARD TURNNIDGE 2023
   21 REM This version is for 16-bit basic but you could adapt
   22 REM Check if we are running in 24-bit BASIC
   24 :
   25 IF HIMEM > &FFFF PRINT "This code will only run on BBC BASIC for Z80": STOP
   30 REM
   31 REM ---------------------------------------------------------
   32 REM This is the i2c assembly code 
   33 REM ---------------------------------------------------------
   36 :
   38 REM allocate plenty of memory spaces for the three machine code commands, could be smaller
   39 :
   40 DIM openi2c% 64
   50 DIM closei2c% 64
   60 DIM writei2c% 64
   70 DIM readi2c% 64
   80 :
   90 REM This routine is for opening the i2c device
   91 :
  100 FOR I%=0 TO 3 STEP 3
  110   P%=openi2c%
  120   [
  130   OPT I%
  140   :
  150   LD c, i2cstruct                 ; Address of the i2c frequency struct
  160   ld a, &1F
  170   RST &08                         ; mos_i2c_open
  180   RET
  190   .i2cstruct
  200   DEFB &A0                        ; LONG (3 bytes) to store frequency (100000)
  210   DEFB &86
  220   DEFB &01
  280   ]
  290 NEXT
 1000 :
 1010 REM This routine is to close the i2c device
 1011 :
 1080 FOR I%=0 TO 3 STEP 3
 1090   P%=closei2c%
 1100   [
 1110   OPT I%
 1120   :
 1210   ld a, &20
 1220   RST &08                         ; mos_i2c_close
 1330   RET
 1370   ]
 1480 NEXT
 1500 :
 2000 REM This routine is to write i2c data
 2001 :
 2010 FOR I%=0 TO 3 STEP 3
 2020   P%=writei2c%
 2030   [
 2040   OPT I%
 2050   :
 2060   ld c, &72                       ; i2c device address (LCD = 0x72)
 2070   ld b, 1                         ; # of bytes to write (max 32)
 2080   ld hl, write_buffer             ; HL Pointer-write_buffer to read bytes
 2090   ld a, &21
 2100   RST &08                         ; mos_i2c_write
 2105   ld hl, 0
 2110   RET
 2115   :
 2120   .write_buffer
 2130   DEFB 65                         ; 14th byte in writei2c%
 2140   ]
 2150 NEXT
 2180 :
 2190 :
 2300 REM This routine is to read i2c data
 2310 FOR I%=0 TO 3 STEP 3
 2320   P%=readi2c%
 2330   [
 2340   OPT I%
 2350   :
 2360   ld c, &72                       ; i2c device address (LCD = 0x72)
 2370   ld b, 3                         ; # of bytes to read (max 32)
 2380   ld hl, read_buffer              ; HL Pointer-read_buffer to write bytes
 2390   ld a, &22
 2400   RST &08                         ; mos_i2c_read
 2405   ld hl, 0
 2410   RET
 2420   .read_buffer
 2430   DEFB 0 : DEFB 0 : DEFB 0
 2440   ]
 2450 NEXT
 2601 :
 2999 :
 3000 REM ---------------------------------------------------------
 3001 REM This is the user Basic program
 3002 REM ---------------------------------------------------------
 3010 REM
 3020 A = writei2c% +14 : REM Char to send to LCD
 3100 CALL openi2c%
 3200 ?A = 124 : REM LCD Settings Mode
 3210 CALL writei2c%
 3220 ?A = 45 : REM LCD Clear the LCD & move cursor to home
 3230 CALL writei2c%
 3240 FOR D = 1 TO 1000 : NEXT : REM Delay >500 mS: ensure splash screen clears
 3245 CLS
 3250 PRINT "(1) Send a message to the LCD"
 3260 PRINT "(2) TDB"
 3270 PRINT "(3) Exit the program"
 3280 INPUT M
 3290 IF M = 1 THEN GOTO 3320
 3300 REM IF M = 2 THEN ?A = 18 : CALL writei2c% : ?A = 84 : CALL writei2c% : GOTO 3245
 3310 IF M <> 1 OR M <> 2 THEN GOTO 4000
 3320 CLS
 3330 PRINT "Serial LCD (3.3VDC) I2C send example."
 3340 PRINT "There are 16|20 characters per line."
 3350 PRINT
 3360 INPUT "Type a message to the serial LCD: " S$
 3370 FOR S = 1 TO LEN(S$)
 3380   ?A = ASC(MID$(S$,S,1))
 3390   CALL writei2c%
 3400 NEXT
 3410 GOTO 3245
 4000 CALL closei2c%
