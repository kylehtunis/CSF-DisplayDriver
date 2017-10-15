;;--------------------------------------------------------------
;;-- user.asm
;;--
;;-- A skeleton user-mode program that calls putc() (i.e., 
;;-- TRAP x07). Obviously missing a loop to display the entire
;;-- string. Also, missing is an exit to return to OS (e.g.,
;;-- TRAP x25).
;;--------------------------------------------------------------

;;============= .TEXT (user) ===================================

.ORIG x2000     ;;-- loads to first page of user memory.

;create the window
	TRAP x23

;call getc() and putc_graphic() repeatedly
LOOP 	TRAP x20
	TRAP x21
	BRnzp LOOP
    
.END
