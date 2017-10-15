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

    LD R0 msg   ;;-- load 1st char as argument for putc().
    TRAP x07    ;;-- call putc( R0 ).

    msg:  .STRINGZ "hello world"

.END
