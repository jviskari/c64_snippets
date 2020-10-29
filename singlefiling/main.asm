.include "defines.inc"

*=$801
    #basic_loader


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