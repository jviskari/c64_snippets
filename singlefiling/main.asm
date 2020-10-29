.include "defines.inc"

*=$801
    ;1sys2064
    .byte $0b, $08, $01, $00, $9e, $32, $30, $36, $34, $00

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