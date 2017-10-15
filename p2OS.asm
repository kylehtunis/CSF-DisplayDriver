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
    LD  R7 USER_start        ;;--   prepare to jump to user.
    JMP R7                   ;;--   jump to USER space at x1000.
                             ;;--
    USER_start: .FILL x1000  ;;--   pointer to USER space.

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

	KBSR: .FILL xFE00
	KBDR: .FILL xFE02

;;----- _putc_graphic( R0 R1 ) -----------
_putc_graphic:

	BRnzp pSTART	
	
	ASCII_Ptr: .FILL AROW0
	SAVED_R1: .FILL x0000
	SAVED_R2: .FILL x0000
	SAVED_R3: .FILL x0000
	SAVED_R4: .FILL x0000

pSTART	ST R1 SAVED_R1	;store values
	ST R2 SAVED_R2
	ST R3 SAVED_R3
	ST R4 SAVED_R4
	LD R2 ASCII_Ptr
	ADD R0 R0 #-16
	ADD R0 R0 #-16
	ADD R0 R0 #-9 ;ascii offset such that A=0
pLOOP	BRz WRITE
	ADD R2 R2 #15
	ADD R2 R2 #15
	ADD R2 R2 #15
	ADD R2 R2 #3
	ADD R0 R0 #-1
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
	
	LDI R1 S1Ptr	;restore values
	LDI R2 S2Ptr
	LDI R3 S3Ptr
	LDI R4 S4Ptr
	JMP R7

	S1Ptr	.FILL SAVED_R1
	S2Ptr	.FILL SAVED_R2
	S3Ptr	.FILL SAVED_R3
	S4Ptr	.FILL SAVED_R4

;;----- _lil_win() -----------
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
	BRnp wLOOP

;create window
BRnzp w2START
WIN_START_Ptr	.FILL xD820
WIN_END_Ptr	.FILL xF8A4
ROW_LEN		.FILL #84
ROW_NUM		.FILL #40
BLACK			.FILL x7FFF
ROW_SIZE		.FILL x0080
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
	LD R1 WIN_START_PTr	

	LD R2 wSAVED_R2 ;restore values
	LD R3 wSAVED_R3
	LD R4 wSAVED_R4
	LD R5 wSAVED_R5
	JMP R7




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
.FILL x7cff
.FILL x7cff
.FILL x7cff
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




.END
