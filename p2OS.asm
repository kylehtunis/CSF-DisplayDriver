;;-----------------------------------------------------------
;;-- OS.asm
;;-- 
;;-- A skeleton OS with one service, putc().
;;-- OS starts in main() and begins its intialization phase.
;;-- That phase calls each OS service's initialization routine.
;;-- The init_putc() routine sets putc()'s TRAP vector.
;;-- The OS, having completed its initialization phase, then
;;-- jumps to the user program.
;;--
;;-- putc() displays one character.
;;-- putc() gets its argument character via register R0.
;;-- putc() uses polling to see if the display is ready.
;;-- putc() is assigned the TVT slot x0007 (i.e., TRAP x07).
;;-------------------------------------------------------------

;;============== .TEXT (kernel) ===============================
.ORIG x5000                  ;;-- Load at start of OS space.

;------- OS main() ----------------
_main:
    JSR _init_putc           ;;--   initialization phase.
	JSR _init_getc
	JSR _init_putc_graphic
	JSR _init_lil_win
    LD  R7 USER_start        ;;--   prepare to jump to user.
    JMP R7                   ;;--   jump to USER space at x1000.
                             ;;--
    USER_start: .FILL x2000  ;;--   pointer to USER space.

;;------ init_putc() --------------
_init_putc:
    LD  R1 putc_TVT          ;;--   R1 <=== TVT slot address.
    LD  R0 putc_ptr          ;;--   R0 <=== putc()'s address.
    STR R0 R1 #0             ;;--   write VT: R0 ===> MEM[R1].
    jmp R7                   ;;--   return to OS main().
                             ;;--
    putc_TVT:   .FILL x0007  ;;--   points to putc()'s TVT slot.
    putc_ptr:   .FILL _putc  ;;--   points to putc().


;;------ init_getc() --------------
_init_getc:
    LD  R1 getc_TVT          ;;--   R1 <=== TVT slot address.
    LD  R0 getc_ptr          ;;--   R0 <=== putc()'s address.
    STR R0 R1 #0             ;;--   write VT: R0 ===> MEM[R1].
    jmp R7                   ;;--   return to OS main().
                             ;;--
    getc_TVT:   .FILL x0020  ;;--   points to putc()'s TVT slot.
    getc_ptr:   .FILL _getc  ;;--   points to putc().


;;------ init_putc_graphic() --------------
_init_putc_graphic:
    LD  R1 putc_graphic_TVT          ;;--   R1 <=== TVT slot address.
    LD  R0 putc_graphic_ptr          ;;--   R0 <=== putc()'s address.
    STR R0 R1 #0             ;;--   write VT: R0 ===> MEM[R1].
    jmp R7                   ;;--   return to OS main().
                             ;;--
    putc_graphic_TVT:   .FILL x0021  ;;--   points to putc()'s TVT slot.
    putc_graphic_ptr:   .FILL _putc_graphic  ;;--   points to putc().

;;------ init_lil_win() --------------
_init_lil_win:
    LD  R1 lil_win_TVT          ;;--   R1 <=== TVT slot address.
    LD  R0 lil_win_ptr          ;;--   R0 <=== putc()'s address.
    STR R0 R1 #0             ;;--   write VT: R0 ===> MEM[R1].
    jmp R7                   ;;--   return to OS main().
                             ;;--
    lil_win_TVT:   .FILL x0023  ;;--   points to putc()'s TVT slot.
    lil_win_ptr:   .FILL _lil_win  ;;--   points to putc().


;;------ _putc( R0 ) ------------------
_putc:
    ST R1 psaved_R1          ;;--   save caller's R1 register.
    poll:                   ;;--   Do
    LDI R1 DSR_ptr          ;;--     read the DSR, R1 <=== DSR;
    BRzp poll               ;;--   until ready, DSR[15] == 1.
    STI R0 DDR_ptr          ;;--   display char, DDR <=== R0.
    LD R1 psaved_R1          ;;--   restore caller's R1.
    JMP R7                  ;;--   return to caller.
                            ;;--
    DDR_ptr:  .FILL xFE06   ;;--   points to DDR.
    DSR_ptr:  .FILL xFE04   ;;--   points to DSR.
    psaved_R1: .FILL x0000   ;;--   space for caller's R1.

;;----- _getc() ----------------
_getc:
gLOOP 	LDI R0 KBSR
	BRzp gLOOP
	LDI R0 KBDR
	RET

	KBSR: .FILL xFE00
	KBDR: .FILL xFE02

;;----- _putc_graphic( R0 R1 ) -----------
_putc_graphic:

	BRnzp pSTART	
	
	ASCII_Ptr: .FILL AROW0
	SPACE .FILL #-32
	SPACEVAL .FILL x5C
	ASCII_Offset .FILL x0041
	SAVED_R1: .FILL x0000
	SAVED_R2: .FILL x0000
	SAVED_R3: .FILL x0000
	SAVED_R4: .FILL x0000

pSTART	ST R1 SAVED_R1	;store values
	ST R2 SAVED_R2
	ST R3 SAVED_R3
	ST R4 SAVED_R4
;check for space
	LD R2 SPACE 
	ADD R2 R0 R2
	BRnp CHAR
	LD R0 SPACEVAL
CHAR LD R2 ASCII_Offset
	NOT R2 R2
	ADD R2 R2 #1
	ADD R3 R0 R2 ;offset ascii such that A=0
	LD R2 ASCII_Ptr
	ADD R3 R3 #0
pLOOP	BRz WRITE
	ADD R2 R2 #15
	ADD R2 R2 #15
	ADD R2 R2 #15
	ADD R2 R2 #15
	ADD R2 R2 #3
	ADD R3 R3 #-1
	BRnzp pLOOP
ROW_ADD .FILL x0080
WRITE	LD R4 ROW_ADD
	LDR R3 R2 #0 ;write row 0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	ADD R1 R1 R4			;next row
	ADD R1 R1 #-7
	LDR R3 R2 #0 ;write row 1
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	ADD R1 R1 R4			;next row
	ADD R1 R1 #-7
	LDR R3 R2 #0 ;write row 2
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	ADD R1 R1 R4			;next row
	ADD R1 R1 #-7
		LDR R3 R2 #0 ;write row 3
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	ADD R1 R1 R4			;next row
	ADD R1 R1 #-7
	LDR R3 R2 #0 ;write row 4
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	ADD R1 R1 R4			;next row
	ADD R1 R1 #-7
	LDR R3 R2 #0 ;write row 5
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	ADD R1 R1 R4			;next row
	ADD R1 R1 #-7
	LDR R3 R2 #0 ;write row 6
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	ADD R1 R1 R4			;next row
	ADD R1 R1 #-7
	LDR R3 R2 #0 ;write row 7
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	ADD R1 R1 R4			;next row
	ADD R1 R1 #-7
	LDR R3 R2 #0 ;write row 8
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	LDR R3 R2 #0
	STR R3 R1 #0
	ADD R1 R1 #1
	ADD R2 R2 #1
	ADD R1 R1 R4			;next row
	ADD R1 R1 #-7
	
END	LDI R1 S1Ptr	;restore values
	LDI R2 S2Ptr
	LDI R4 S4Ptr
	ADD R1 R1 #7 ;increment cursor
;check for next line
	ADD R2 R2 #1
	ADD R3 R2 #-12
	BRn C
	LD R2 NEXT_LINE
	ADD R1 R1 R2
	AND R2 R2 #0
;check if drawing cursor
C	LD R3 CURSOR
	NOT R3 R3
	ADD R3 R3 #1
	ADD R3 R0 R3
	BRz NEXT
;draw the cursor
	ST R1 wSAVED_R1
	ST R2 wSAVED_R2
	ST R7 SAVED_R7
	LD R0 CURSOR
	TRAP x21
	LD R1 wSAVED_R1
	LD R2 wSAVED_R2
	LD R7 SAVED_R7





NEXT LDI R3 S3Ptr

	JMP R7

	NEXT_LINE .FILL x04AC
	S1Ptr	.FILL SAVED_R1
	S2Ptr	.FILL SAVED_R2
	S3Ptr	.FILL SAVED_R3
	S4Ptr	.FILL SAVED_R4
	SAVED_R7 .FILL x0000

;;----- _lil_win() -----------
_lil_win:
;fill background blue
	BRnzp wSTART
	wSAVED_R1: .FILL x0000
	wSAVED_R2: .FILL x0000
	wSAVED_R3: .FILL x0000
	wSAVED_R4: .FILL x0000
	wSAVED_R5: .FILL x0000

	
	VRAM_END	.FILL xFDFF
	VRAM_START	.FILL xC000
	BLUE		.FILL x001F
wSTART	ST R1 wSAVED_R1	;store values
	ST R2 wSAVED_R2
	ST R3 wSAVED_R3
	ST R4 wSAVED_R4
	ST R5 wSAVED_R5
	LD R1 VRAM_END
	LD R2 VRAM_START
	LD R3 BLUE
	NOT R2 R2
	ADD R2 R2 #1
wLOOP	STR R3 R1 #0
	ADD R1 R1 -1
	ADD R4 R1 R2
	BRp wLOOP

;create window
BRnzp w2START
WIN_START_Ptr	.FILL xD714
WIN_END_Ptr	.FILL xE368
ROW_LEN		.FILL #84
ROW_NUM		.FILL #40
BLACK			.FILL x7FFF
ROW_SIZE		.FILL x007F
w2START	LD R1 WIN_END_Ptr
	LD R2 ROW_LEN
	LD R3 ROW_NUM
	LD R4 BLACK
	LD R5 ROW_SIZE
	NOT R5 R5
	ADD R5 R5 #1
LOOP	STR R4 R1 #0
	ADD R1 R1 #-1
	ADD R2 R2 #-1
	BRzp LOOP
	LD R2 ROW_LEN
	ADD R1 R1 R2
	ADD R1 R1 R5
	ADD R3 R3 #-1
	BRzp LOOP

;initialize the cursor in R1
	LD R1 WIN_START_Ptr	
	LD R3 OFFSET
	ADD R1 R1 R3
	AND R2 R2 #0
	ADD R2 R2 #-1

;draw the cursor
	ST R1 wSAVED_R1
	ST R7 SAVED_R7
	LD R0 CURSOR
	TRAP x21
	LD R1 wSAVED_R1
	LD R7 SAVED_R7

	LD R3 wSAVED_R3  ;restore values
	LD R4 wSAVED_R4
	LD R5 wSAVED_R5
	JMP R7

OFFSET .FILL #-1792
CURSOR .FILL x5B



;;DATA:
AROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

AROW1:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

AROW2:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

AROW3:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

AROW4:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

AROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

AROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

AROW7:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff


AROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

BROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

BROW1:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

BROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

BROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

BROW4:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

BROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

BROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

BROW7:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

BROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CROW1:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

CROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

CROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CROW4:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

CROW7:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

CROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

DROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

DROW1:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

DROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

DROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

DROW4:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

DROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

DROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

DROW7:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

DROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

EROW0:	.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff

EROW1:	.FILL x7fff 
.FILL x7fff 
.FILL x7c00 
.FILL x7c00 
.FILL x7c00 
.FILL x7c00 
.FILL x7fff

EROW2:	.FILL x7fff 
.FILL x7fff 
.FILL x7c00 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff

EROW3:	.FILL x7fff 
.FILL x7fff 
.FILL x7c00 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff

EROW4:	.FILL x7fff 
.FILL x7fff 
.FILL x7c00 
.FILL x7c00 
.FILL x7c00 
.FILL x7fff 
.FILL x7fff

EROW5:	.FILL x7fff 
.FILL x7fff 
.FILL x7c00 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff

EROW6:	.FILL x7fff 
.FILL x7fff 
.FILL x7c00 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff

EROW7:	.FILL x7fff 
.FILL x7fff 
.FILL x7c00 
.FILL x7c00 
.FILL x7c00 
.FILL x7c00 
.FILL x7fff

EROW8:	.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff 
.FILL x7fff

FROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

FROW1:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

FROW2:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

FROW3:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

FROW4:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

FROW5:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

FROW6:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

FROW7:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

FROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

GROW0:	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff

GROW1:	.FILL x7fff
	.FILL x7fff
	.FILL x7c00
	.FILL x7c00
	.FILL x7c00
	.FILL x7fff
	.FILL x7fff

GROW2:	.FILL x7fff
	.FILL x7c00
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7c00
	.FILL x7fff

GROW3:	.FILL x7fff
	.FILL x7c00
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff

GROW4:	.FILL x7fff
	.FILL x7c00
	.FILL x7fff
	.FILL x7c00
	.FILL x7c00
	.FILL x7c00
	.FILL x7fff

GROW5:	.FILL x7fff
	.FILL x7c00
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7c00
	.FILL x7fff

GROW6:	.FILL x7fff
	.FILL x7c00
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7c00
	.FILL x7fff

GROW7:	.FILL x7fff
	.FILL x7fff
	.FILL x7c00
	.FILL x7c00
	.FILL x7c00
	.FILL x7fff
	.FILL x7fff

GROW8:	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff
	.FILL x7fff

HROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

HROW1:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

HROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

HROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

HROW4:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

HROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

HROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

HROW7:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

HROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

IROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

IROW1:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

IROW2:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

IROW3:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

IROW4:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

IROW5:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

IROW6:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

IROW7:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

IROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

JROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

JROW1:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

JROW2:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

JROW3:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

JROW4:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

JROW5:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

JROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

JROW7:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

JROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

KROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

KROW1:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

KROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

KROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

KROW4:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

KROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

KROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

KROW7:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

KROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

LROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

LROW1:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

LROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

LROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

LROW4:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

LROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

LROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

LROW7:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

LROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

MROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

MROW1:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

MROW2:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7fff

MROW3:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

MROW4:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff

MROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

MROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

MROW7:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

MROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

NROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

NROW1:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

NROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

NROW3:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

NROW4:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff

NROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7fff

NROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

NROW7:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

NROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

OROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

OROW1:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

OROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

OROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

OROW4:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

OROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

OROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

OROW7:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

OROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

PROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

PROW1:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

PROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

PROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

PROW4:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

PROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

PROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

PROW7:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

PROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

QROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

QROW1:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

QROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

QROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

QROW4:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

QROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff

QROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7fff

QROW7:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

QROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

RROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

RROW1:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

RROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

RROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

RROW4:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

RROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

RROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

RROW7:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

RROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SROW1:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

SROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SROW4:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

SROW5:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

SROW6:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

SROW7:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

SROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

TROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

TROW1:	.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

TROW2:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

TROW3:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

TROW4:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

TROW5:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

TROW6:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

TROW7:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

TROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

UROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

UROW1:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

UROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

UROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

UROW4:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

UROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

UROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

UROW7:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff
.FILL x7fff

UROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

VROW0: .FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

VROW1: .FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

VROW2: .FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

VROW3: .FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

VROW4: .FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

VROW5: .FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

VROW6: .FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

VROW7: .FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

VROW8: .FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

WROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

WROW1:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

WROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

WROW3:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

WROW4:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff

WROW5:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff

WROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff

WROW7:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

WROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

XROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

XROW1:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

XROW2:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

XROW3:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

XROW4:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

XROW5:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

XROW6:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

XROW7:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

XROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

YROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

YROW1:	.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

YROW2:	.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

YROW3:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

YROW4:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

YROW5:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

YROW6:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

YROW7:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

YROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

ZROW0:	.FIll x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

ZROW1: .FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

ZROW2: .FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff

ZROW3: .FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff

ZROW4: .FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff

ZROW5: .FILL x7fff
.FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

ZROW6: .FILL x7fff
.FILL x7c00
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

ZROW7: .FILL x7fff
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7c00
.FILL x7fff

ZROW8: .FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CURROW0 .FILL x0000
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CURROW1 .FILL x0000
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CURROW2 .FILL x0000
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CURROW3 .FILL x0000
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CURROW4 .FILL x0000
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CURROW5 .FILL x0000
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CURROW6 .FILL x0000
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CURROW7 .FILL x0000
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

CURROW8 .FILL x0000
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SPROW0:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SPROW1:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SPROW2:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SPROW3:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SPROW4:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SPROW5:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SPROW6:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SPROW7:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff

SPROW8:	.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff
.FILL x7fff


.END
