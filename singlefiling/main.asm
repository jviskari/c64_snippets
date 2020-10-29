.include "defines.inc"

    #basic_start "2064"

*=MAIN_PROG

    jsr GREEN_PROG
    jsr wait
    jsr WHITE_PROG
    jsr wait
    jmp MAIN_PROG

wait
    ldx #255
-   dex
    bne -
    rts